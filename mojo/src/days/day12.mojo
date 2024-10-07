from advent_utils import AdventSolution
from algorithm import parallelize


fn calc_line(line: String) raises -> Int32:
    goods = 0
    temps = 0
    p = line.find(" ") + 1
    source, target = line[:p], line[p + 1 :]
    src_idx, tgt_idx = 0, 0
    t, s = target[0], source[0]
    try:
        it = int(t)
    except:
        it = 0

    while True:
        if it:
            if s == ".":
                return 0
            elif temps + 1 > it:
                goods -= 1
            elif s == "?":
                temps += 1
            if s == "#":
                goods += 1
        elif t == ",":
            ...
        else:
            ...
        if tgt_idx == target.byte_length():
            break

    return iters


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
