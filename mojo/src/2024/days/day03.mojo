struct Solution:
    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        """Part 1 solution.

        ```mojo
        from advent_utils import test
        from days.day03 import Solution

        test[Solution, file="tests/2024/day03.txt", part=1, expected=161]()
        ```
        """
        pos = 0
        tot = 0
        while pos < len(data):
            pi = data.find("mul(", pos)
            if pi == -1:
                break
            pi += 4
            pc = data.find(",", start=pi + 1)
            if pc == -1:
                break
            try:
                n1 = int(data[pi:pc])
            except:
                pos = pi + 1
                continue

            pf = data.find(")", pc + 2)
            if pf == -1:
                break

            try:
                n2 = int(data[pc + 1 : pf])
            except:
                pos = pc + 1
                continue

            pos = pf + 1
            tot += n1 * n2
        return tot

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        from days.day03 import Solution

        test[Solution, file="tests/2024/day032.txt", part=2, expected=48]()
        ```
        """
        pos = 0
        tot = 0
        n_dont = data.find("don't()")
        while pos < len(data):
            pi = data.find("mul(", pos)
            if pi == -1:
                # print("mul( not found")
                break

            if n_dont > -1 and n_dont < pi:
                do = data.find("do()", pos + 7)
                if do == -1:
                    break
                pos = do + 4
                n_dont = data.find("don't()", pos)
                continue

            pi += 4
            pc = data.find(",", start=pi + 1)
            if pc == -1:
                break
            try:
                n1 = int(data[pi:pc])
            except:
                pos = pi + 1
                continue

            pf = data.find(")", pc + 2)
            if pf == -1:
                break

            try:
                n2 = int(data[pc + 1 : pf])
            except:
                pos = pc + 1
                continue

            pos = pf + 1
            tot += n1 * n2
        return tot
