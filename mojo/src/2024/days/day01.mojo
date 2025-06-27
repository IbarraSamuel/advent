from collections import Counter
from advent_utils import AdventSolution


struct Solution(AdventSolution):
    alias T = Int32

    @staticmethod
    fn part_1[o: ImmutableOrigin](data: StringSlice[o]) -> Self.T:
        """Part 1 test.

        ```mojo
        from days.day01 import Solution
        from advent_utils import test
        test[Solution, file="tests/2024/day01.txt", part=1, expected=11]()
        ```
        """
        alias ordoff: Int = ord("0")
        alias spaceord: Int = ord(" ")

        # pos = 0
        # lines_size = 1

        # spaces = List[Int](capacity=1024)
        ref lines = data.splitlines()
        lines_size = len(lines)

        # while True:
        #     pos = data.find("\n", pos)
        #     if pos == -1:
        #         break

        #     spaces[lines_size] = pos + 1
        #     spaces.append(0)
        #     pos += 1
        #     lines_size += 1

        # if not data.endswith("\n"):
        #     spaces[lines_size] = data.byte_length()

        l1 = List[Int](capacity=lines_size)
        l2 = List[Int](capacity=lines_size)

        # for line_idx in range(lines_size - 1):
        #     init = Int(spaces[line_idx])
        #     end = Int(spaces[line_idx + 1])
        #     line = data[init : end - 1]
        for ref line in lines:
            v1, v2 = 0, 0
            no1 = line.find(" ")
            no2 = line.rfind(" ") + 1
            try:
                v1, v2 = Int(line[:no1]), Int(line[no2:])
            except:
                pass
            # for chr in line:
            #     spc = chr.find(" ")
            #     if chr != spaceord:
            #         v1 += v1 * 10 + (Int(chr) - ordoff)
            #     if v2 == 0 and chr == spaceord:
            #         continue
            #     if chr == spaceord:
            #         v1, v2 = v2, 0
            #         continue

            #     v2 += v2 * 10 + (Int(chr) - ordoff)
            l1.append(v1)
            l2.append(v2)

        sort(l1)
        sort(l2)

        t = 0
        for i in range(lines_size):
            t += abs(l2[i] - l1[i])
        return t

    @staticmethod
    fn part_2[o: ImmutableOrigin](data: StringSlice[o]) -> Self.T:
        """Part 2 test.

        ```mojo
        from days.day01 import Solution
        from advent_utils import test
        test[Solution, file="tests/2024/day01.txt", part=2, expected=31]()
        ```
        """
        lines = data.splitlines()
        vals: List[StringSlice[o]] = [
            line.split(maxsplit=1)[1] for ref line in lines
        ]

        dct = Dict[StringSlice[o], Int]()
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
