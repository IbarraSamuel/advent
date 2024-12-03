from pathlib import Path
from advent_utils import test, Part


struct Solution:
    """
    This is the solution for the day 1.

    The solution should satisfy:
    ```mojo
    from advent_utils import test, PART_1
    from days.day01 import Solution

    test[Solution, day=1, part=1, expected=11]()
    ```
    """

    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        lines = data.splitlines()
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
