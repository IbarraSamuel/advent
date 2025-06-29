from advent_utils import AdventSolution


alias `M` = ord('M')
alias `A` = ord('A')
alias `S` = ord('S')

struct Solution(AdventSolution):
    alias T = Int32

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
        """Part 1 solution.

        ```mojo
        from advent_utils import test
        import days

        test[days.day04.Solution, file="tests/2024/day04.txt", part=1, expected=18]()
        test[days.day04.Solution, file="tests/2024/day044.txt", part=1, expected=4]()
        ```
        """
        tot = 0
        bytes = data.as_bytes()
        xmax = data.find('\n')
        ymax = len(bytes) // (xmax + 1)

        @parameter
        @always_inline
        fn idx(x: Int, y: Int) -> Int:
            return x + y * (xmax + 1)
        
        last = 0
        while True:
            lnr = data.find("X", start=last)
            if lnr == -1:
                break

            last = lnr + 1
            x, y = lnr % (xmax + 1), lnr // (xmax + 1)

            tot += Int(x < xmax - 3
                and bytes[idx(x + 1, y)] == `M`
                and bytes[idx(x + 2, y)] == `A`
                and bytes[idx(x + 3, y)] == `S`)
                + (x > 2
                    and bytes[idx(x - 1, y)] == `M`
                    and bytes[idx(x - 2, y)] == `A`
                    and bytes[idx(x - 3, y)] == `S`)
                + (x < xmax - 3
                    and y < ymax - 3
                    and bytes[idx(x + 1, y + 1)] == `M`
                    and bytes[idx(x + 2, y + 2)] == `A`
                    and bytes[idx(x + 3, y + 3)] == `S`)
                + (x > 2
                    and y > 2
                    and bytes[idx(x - 1, y - 1)] == `M`
                    and bytes[idx(x - 2, y - 2)] == `A`
                    and bytes[idx(x - 3, y - 3)] == `S`)
                + (x < xmax - 3
                    and y > 2
                    and bytes[idx(x + 1, y - 1)] == `M`
                    and bytes[idx(x + 2, y - 2)] == `A`
                    and bytes[idx(x + 3, y - 3)] == `S`)
                + (x > 2
                    and y < ymax - 3
                    and bytes[idx(x - 1, y + 1)] == `M`
                    and bytes[idx(x - 2, y + 2)] == `A`
                    and bytes[idx(x - 3, y + 3)] == `S`)
                + (y < ymax - 3
                    and bytes[idx(x, y + 1)] == `M`
                    and bytes[idx(x, y + 2)] == `A`
                    and bytes[idx(x, y + 3)] == `S`)
                + (y > 2
                    and bytes[idx(x, y - 1)] == `M`
                    and bytes[idx(x, y - 2)] == `A`
                    and bytes[idx(x, y - 3)] == `S`)


        return tot            


    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        import days

        test[days.day04.Solution, file="tests/2024/day032.txt", part=2, expected=9]()
        ```
        """
        tot = 0
        xmax = data.find("\n")
        bts = data.as_bytes()
        ymax = len(data) // (xmax + 1)

        @always_inline
        @parameter
        fn idx(x: Int, y: Int) -> Int:
            return x + y * (xmax + 1)

        last = xmax + 3
        while True:
            lnr = data.find("A", last)
            if lnr == -1 or lnr // (xmax + 1) == ymax - 1:
                break
            last = lnr + 1

            x, y = lnr % (xmax + 1), lnr // (xmax + 1)
            tot += Int(x > 0 and x < xmax - 1 and (
                bts[idx(x - 1, y - 1)] == `M`
                and bts[idx(x + 1, y + 1)] == `S`
                or bts[idx(x - 1, y - 1)] == `S`
                and bts[idx(x + 1, y + 1)] == `M`
            ) and (
                bts[idx(x - 1, y + 1)] == `M`
                and bts[idx(x + 1, y - 1)] == `S`
                or bts[idx(x - 1, y + 1)] == `S`
                and bts[idx(x + 1, y - 1)] == `M`
            ))

        return tot
