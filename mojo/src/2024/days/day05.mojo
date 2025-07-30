from advent_utils import AdventSolution
from algorithm import parallelize


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
        tot = SIMD[DType.int32, 1024](0)
        order_split = data.find("\n\n")
        rest = data[order_split + 2 :]
        order = data[0:order_split]

        # NEW
        next_dct = Dict[
            StringSlice[data.origin], List[StringSlice[data.origin]]
        ]()
        prev_dct = Dict[
            StringSlice[data.origin], List[StringSlice[data.origin]]
        ]()

        prev_idx = 0

        while True:
            var lnr = order.find("\n", prev_idx)
            if lnr == -1:
                break
            var mid = order.find("|", prev_idx)
            next_dct.setdefault(order[prev_idx:mid], []).append(
                order[mid + 1 : lnr]
            )
            prev_dct.setdefault(order[mid + 1 : lnr], []).append(
                order[prev_idx:mid]
            )
            prev_idx = lnr + 1

        lines = rest.splitlines()

        @parameter
        fn calc(idx: Int):
            line = lines[idx]
            var readed_idx = 3
            while True:
                if line[readed_idx - 1] == "\n":
                    # We finalize the line
                    nbr = line[len(line) // 2 - 1 : len(line) // 2 + 1]
                    bts = nbr.as_bytes()
                    tot[idx] = (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * zord
                        + bts[1].cast[DType.int32]()
                    )
                    break

                val = line[readed_idx : readed_idx + 2]
                prev_values = line[:readed_idx]

                # if val in prev_dct:
                res = prev_dct.get(val)
                found = False
                if res:
                    for v in res.unsafe_value():
                        if v in prev_values:
                            found = True
                            break

                if found == False:
                    break

                # no next should be found
                res = next_dct.get(val)
                found = False
                if res:
                    for v in res.unsafe_value():
                        if v in prev_values:
                            found = True
                            break

                if found == True:
                    break

                readed_idx += 3

        parallelize[calc](len(lines))
        return tot.reduce_add()

    @staticmethod
    fn part_2(data: StringSlice[mut=False]) -> Self.T:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        from days.day01 import Solution

        test[Solution, file="tests/2024/day05.txt", part=2, expected=123]()
        ```
        """
        tot = Int32(0)

        alias zord = ord("0")
        order_split = data.find("\n\n")
        rest = data[order_split + 2 :]
        order = data[0:order_split]

        # NEW
        next_dct = Dict[
            StringSlice[data.origin], List[StringSlice[data.origin]]
        ]()
        prev_dct = Dict[
            StringSlice[data.origin], List[StringSlice[data.origin]]
        ]()

        prev_idx = 0

        while True:
            var lnr = order.find("\n", prev_idx)
            if lnr == -1:
                break
            var mid = order.find("|", prev_idx)
            next_dct.setdefault(order[prev_idx:mid], []).append(
                order[mid + 1 : lnr]
            )
            prev_dct.setdefault(order[mid + 1 : lnr], []).append(
                order[prev_idx:mid]
            )
            prev_idx = lnr + 1

        for line in rest.splitlines():
            line_values = line.split(",")
            bad = False
            for i in range(len(line_values)):
                ref v = line_values.unsafe_get(i)

                next_for_v = next_dct.get(v).or_else([])
                # prev_for_v = prev_dct.get(v).or_else([])

                prev_in_line = line_values[:i]
                # one_prev_is_there = False
                for pi in range(i):  # length of prev_in_line
                    ref piv = prev_in_line.unsafe_get(pi)
                    # if piv in prev_for_v:
                    #     one_prev_is_there = True

                    if piv in next_for_v:
                        # It means we have to move v to be before pv
                        bad = True
                        move = line_values.pop(i)
                        line_values.insert(pi, move)

                # if not one_prev_is_there and len(prev_for_v) > 0:
                #     idx = -1
                #     for pp in prev_for_v:
                #         try:
                #             idx = line_values.index(pp)
                #         except:
                #             pass

                #     if idx == -1:
                #         os.abort("This is wrong!!!!!!!!!!!!!!!")

                #     ....

            if bad:
                bts = line_values.unsafe_get(len(line_values) // 2).as_bytes()

                tot += (
                    10 * bts[0].cast[DType.int32]()
                    - 11 * zord
                    + bts[1].cast[DType.int32]()
                )
        return tot
