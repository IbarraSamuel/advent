from advent_utils import AdventSolution
from algorithm import parallelize


fn calc_line(ref [_]line: String) -> Int32:
    return 0


fn calc_line_2(ref [_]line: String) -> Int32:
    return 0


struct Solution(AdventSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        r = SIMD[DType.int32, 1024](0)

        @parameter
        fn calc(idx: Int):
            r[idx] = calc_line(lines.unsafe_get(idx))

        parallelize[calc](lines.size)
        return r.reduce_add()

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        r = SIMD[DType.int32, 1024](0)

        @parameter
        fn calc(idx: Int):
            r[idx] = calc_line_2(lines.unsafe_get(idx))

        parallelize[calc](lines.size)
        return r.reduce_add()
