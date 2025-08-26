from advent_utils import AdventSolution
from algorithm import parallelize
from collections import Set
from os import abort


fn build_indexes[dtype: DType, size: Int]() -> SIMD[dtype, size]:
    var res = SIMD[dtype, size](0)
    for i in range(size):
        res[i] = i
    return res


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
        alias zord = ord("0")
        alias indexes = build_indexes[DType.uint8, 32]()
        tot = SIMD[DType.int32, 1024](0)

        split_idx = data.find("\n\n")

        rules = [(r[:2], r[3:]) for r in data[0:split_idx].splitlines()]
        manuals = data[split_idx + 2 :].splitlines()

        @parameter
        fn calc_line(idx: Int):
            ref page = manuals[idx]
            for f, l in rules:
                fi = page.find(f)
                li = page.find(l)
                if fi > -1 and li > -1 and fi > li:
                    var _idxs = order_manual[indexes](page, rules)
                    var middle = len(page) // 2
                    var _mididx = _idxs[(middle - 1) // 3]
                    var _middle = Int(_mididx * 3) + 1
                    var _nbr = page[_middle - 1 : _middle + 1]

                    bts = _nbr.as_bytes()
                    tot[idx] = (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * zord
                        + bts[1].cast[DType.int32]()
                    )
                    break

        parallelize[calc_line](len(manuals))
        return tot.reduce_add()


fn order_manual[
    o: Origin, //,
    indexes: SIMD[DType.uint8, 32],
    zeroidx: SIMD[DType.uint8, 32] = SIMD[DType.uint8, 32](0),
](
    page: StringSlice[o],
    rules: List[Tuple[StringSlice[o], StringSlice[o]]],
) -> SIMD[DType.uint8, 32]:
    var done = False
    var idx = indexes.copy()
    used_rules = List[Tuple[StringSlice[o], StringSlice[o]]]()
    for first, last in rules:
        of = page.find(first)
        ol = page.find(last)
        if of > -1 and ol > -1:
            used_rules.append((first, last))
            fi = idx.eq(of // 3).select(indexes, zeroidx).reduce_max()
            li = idx.eq(ol // 3).select(indexes, zeroidx).reduce_max()
            if fi > li:
                idx[Int(fi)], idx[Int(li)] = idx[Int(li)], idx[Int(fi)]

    while not done:
        done = True
        for first, last in used_rules:
            of = page.find(first)
            ol = page.find(last)
            fi = idx.eq(of // 3).select(indexes, zeroidx).reduce_max()
            li = idx.eq(ol // 3).select(indexes, zeroidx).reduce_max()
            if fi > li:
                done = False
                idx[Int(fi)], idx[Int(li)] = idx[Int(li)], idx[Int(fi)]

    return idx


# fn order_manual[
#     mo: MutableOrigin, o: Origin
# ](
#     mut page: StringSlice[mo],
#     rules: List[Tuple[StringSlice[o], StringSlice[o]]],
# ):
#     for _ in range(page.count(",") + 1):
#         for first, last in rules:
#             if first in page and last in page:
#                 fi, li = page.find(first), page.find(last)
#                 try:
#                     if fi > li:
#                         page.as_bytes().swap_elements(fi, li)
#                         page.as_bytes().swap_elements(fi + 1, li + 1)
#                         # page[page.find(first) : page.find(first) + 2], page[
#                         #     page.find(last) : page.find(last) + 2
#                         # ] = (
#                         #     page[page.find(last) : page.find(last) + 2],
#                         #     page[page.find(first) : page.find(first) + 2],
#                         # )
#                 except:
#                     pass
# return page
