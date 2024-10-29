struct Solution:
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        total = Int32()
        for line in lines:
            total += calc_line(line[])
        return total

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        total = Int32()
        for line in lines:
            total += calc_line(line[])
        return total


fn calc_line(line: String) -> Int32:
    return len(line)
