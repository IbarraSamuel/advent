from advent_utils import AdventSolution
from algorithm import parallelize

alias min_num_byte = ord("0")
alias max_num_byte = ord("9")


fn calc_line(line: String) -> Int32:
    """Try to explore the check as just checking if with this additional dots, if the option is still valid. Just keep adding dots and do math to reduce from all possibitilies to those what cannot be because are no spaces to meet the group requirements.
    """
    space_idx = line.find(" ")
    signature = line[:space_idx]
    groups = line[space_idx + 1 :]

    sig_idx = 0
    while signature[sig_idx] == ".":
        sig_idx += 1

    for chr in groups:
        if chr == ".":
            pass
        try:
            n = int(chr)
        except:
            pass

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
