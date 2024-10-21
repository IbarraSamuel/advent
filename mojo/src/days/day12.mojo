from advent_utils import AdventSolution
from algorithm import parallelize

alias min_num_byte = ord("0")
alias max_num_byte = ord("9")


fn calc_line(line: String) -> Int32:
    return 0


fn calc_line_2(line: String) -> Int32:
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
