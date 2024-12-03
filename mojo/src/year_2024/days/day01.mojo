from pathlib import Path
from advent_utils import test


struct Solution:
    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        return 0

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        return 0


fn test_part_1() raises:
    path = Path() / "../tests/2023/day01.txt"
    with open(path, "r") as f:
        data = f.read()

    r1 = Solution.part_1(data)
    assert_eq
