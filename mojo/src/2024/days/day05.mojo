from advent_utils import AdventSolution
from algorithm import parallelize
from collections import Set


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
        split_idx = data.find("\n\n")

        rules = [(r[:2], r[3:]) for r in data[0:split_idx].splitlines()]
        manuals = data[data.find("\n\n") + 2 :].splitlines()

        for page in manuals:
            var valid = True
            for f, l in rules:
                if f in page and l in page:
                    if page.find(f) > page.find(l):
                        valid = False
                        break
            if not valid:
                var mut_page = String(page)
                var mut_slice = mut_page.as_string_slice_mut()
                order_manual[o = data.origin](mut_slice, rules)
                try:
                    middle = len(mut_slice) // 2
                    tot += Int(mut_slice[middle - 1 : middle + 1])
                except:
                    pass

        return tot


fn order_manual[
    mo: MutableOrigin, o: Origin
](
    mut page: StringSlice[mo],
    rules: List[Tuple[StringSlice[o], StringSlice[o]]],
):
    for _ in range(page.count(",") + 1):
        for first, last in rules:
            if first in page and last in page:
                fi, li = page.find(first), page.find(last)
                try:
                    if fi > li:
                        page.as_bytes().swap_elements(fi, li)
                        page.as_bytes().swap_elements(fi + 1, li + 1)
                        # page[page.find(first) : page.find(first) + 2], page[
                        #     page.find(last) : page.find(last) + 2
                        # ] = (
                        #     page[page.find(last) : page.find(last) + 2],
                        #     page[page.find(first) : page.find(first) + 2],
                        # )
                except:
                    pass
    # return page
