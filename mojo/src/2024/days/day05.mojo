from advent_utils import AdventSolution


struct Solution(AdventSolution):
    alias T = Int32

    @staticmethod
    fn part_1(data: StringSlice[mut=False]) -> Self.T:
        """Part 1 solution.

        ```mojo
        from advent_utils import test
        from days.day01 import Solution

        test[Solution, file="tests/2024/day05.txt", part=1, expected=143]()
        ```
        """
        alias zord = ord("0")
        tot = Int32(0)
        order_split = data.find("\n\n")
        order = data[0:order_split]
        rest = data[order_split + 2 :]

        for line in rest.splitlines():
            var readed_idx = 3
            while True:
                if line[readed_idx - 1] == "\n":
                    # We finalize the line
                    nbr = line[len(line) // 2 - 1 : len(line) // 2 + 1]
                    bts = nbr.as_bytes()
                    tot += (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * zord
                        + bts[1].cast[DType.int32]()
                    )
                    break

                val = line[readed_idx : readed_idx + 2]
                var ord_idx = order.find("|" + val)
                var req_met = False

                while ord_idx != -1:
                    requisite = order[ord_idx - 2 : ord_idx]
                    if line[:readed_idx].find(requisite) != -1:
                        oidx = order.find(val + "|")
                        while oidx != -1:
                            req = order[oidx + 3 : oidx + 5]
                            if line[:readed_idx].find(req) != -1:
                                break
                            oidx = order.find(val + "|", oidx + 1)
                        else:
                            req_met = True
                            break
                    ord_idx = order.find("|" + val, ord_idx + 1)

                if not req_met:
                    break

                readed_idx += 3

        return tot

    @staticmethod
    fn part_2(data: StringSlice[mut=False]) -> Self.T:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        from days.day01 import Solution

        test[Solution, file="tests/2024/day05.txt", part=2, expected=0]()
        ```
        """
        tot = 0
        return tot
