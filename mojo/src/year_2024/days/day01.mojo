from pathlib import Path
from advent_utils import test


struct Solution:
    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        lines = data.split()
        t1, t2 = 0, 0
        try:
            for line in lines:
                ns = line[].split()
                t1 += int(ns[0])
                t2 += int(ns[1])
        except:
            pass
        return t2 - t1

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        return 0


fn test_part_1() raises:
    path = Path() / "../tests/2023/day01.txt"
    with open(path, "r") as f:
        data = f.read()

    r1 = Solution.part_1(data)
    assert_eq
