from pathlib import Path
from advent_utils import test, Part
from collections import Counter


struct Solution:
    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        """Part 1 test.

        ```mojo
        from days.day01 import Solution, test
        from testing import assert_equal
        test[Solution, file="tests/2024/day01.txt", part=1, expected=11]()
        ```
        """
        lines = data.splitlines()
        lines_size = len(lines)
        l1 = List[Int](capacity=lines_size)
        l2 = List[Int](capacity=lines_size)
        t = 0
        try:
            for line in lines:
                ns = line[].split()
                l1.append(int(ns[0]))
                l2.append(int(ns[1]))
            sort(l1)
            sort(l2)

            for i in range(lines_size):
                t += abs(l2[i] - l1[i])
        except:
            pass
        return t

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        """Part 2 test.

        ```mojo
        from days.day01 import Solution, test
        from testing import assert_equal
        test[Solution, file="tests/2024/day01.txt", part=2, expected=31]()
        ```
        """
        lines = data.splitlines()
        vals = List[String]()
        for line in lines:
            vals.append(line[].split()[1])

        c = Counter[String](vals)
        tot = 0
        for line in lines:
            k = line[].split()[0]
            try:
                tot += int(k) * c.get(k, 0)
            except:
                pass
        return tot
