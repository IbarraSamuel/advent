from advent_utils import AdventSolution


struct Solution(AdventSolution):
    alias T = Int32

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
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
            var readed_idx = line.find(",") + 1
            while True:
                var new_idx = line.find(",", readed_idx)
                if new_idx == -1:
                    # We finalize the line
                    nbr = line[len(line) // 2 - 1 : len(line) // 2 + 1]
                    bts = nbr.as_bytes()
                    tot += (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * zord
                        + bts[1].cast[DType.int32]()
                    )
                    break

                val = line[readed_idx:new_idx]
                var ord_idx = order.find("|" + val)
                if ord_idx == -1:
                    print("No order for the value:", val)
                    readed_idx = new_idx + 1
                    continue

                while True:
                    if line.find(order[ord_idx - 2 : ord_idx]) != -1:
                        ord_idx = order.find("|" + val, ord_idx + 1)
                        if ord_idx == -1:
                            break
                        continue
                    if ord_idx == -1:
                        break
                else:
                    print(
                        "for val:",
                        val,
                        "the value needed before is not before. pref:",
                        order[ord_idx - 2 : ord_idx],
                        "is not in",
                        line,
                    )
                    break

                print(val, order[ord_idx - 2 : ord_idx])
                readed_idx = new_idx + 1

        return tot

    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        from days.day01 import Solution

        test[Solution, file="tests/2024/day05.txt", part=2, expected=0]()
        ```
        """
        tot = 0
        return tot
