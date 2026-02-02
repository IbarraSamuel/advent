from collections import Counter
from advent_utils import AdventSolution


struct Solution(AdventSolution):
    comptime T = Int32

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
        """Part 1 test.

        ```mojo
        from aoc2025.day01 import Solution
        from advent_utils import test_solutions
        test[Solution, file="tests/2024/day01.txt", part=1, expected=11]()
        ```
        """
        lines = data.splitlines()
        lines_size = len(lines)

        l1 = List[Int](capacity=lines_size)
        l2 = List[Int](capacity=lines_size)

        for line in lines:
            v1, v2 = 0, 0
            no1 = line.find(" ")
            no2 = line.rfind(" ") + 1
            try:
                v1, v2 = Int(line[:no1]), Int(line[no2:])
            except:
                pass

            l1.append(v1)
            l2.append(v2)

        sort(l1)
        sort(l2)

        t = 0
        for i in range(lines_size):
            t += abs(l2[i] - l1[i])
        return t

    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
        """Part 2 test.

        ```mojo
        from aoc2025.day01 import Solution
        from advent_utils import test
        test[Solution, file="tests/2024/day01.txt", part=2, expected=31]()
        ```
        """
        lines = data.splitlines()
        vals = [line.split(maxsplit=1)[1] for line in lines]
        dct = Dict[vals.T, Int]()

        for val in vals:
            dct[val] = dct.get(val, 0) + 1

        tot = 0
        for line in lines:
            k = line.split(maxsplit=1)[0]
            try:
                tot += Int(k) * dct.get(k, 0)
            except:
                pass
        return tot
