from std.algorithm import parallelize
from std.collections import Set
from std.os import abort
from std.math import log2
from std.memory.unsafe import pack_bits

from advent_utils import AdventSolution


fn build_indexes[dtype: DType, size: Int]() -> SIMD[dtype, size]:
    var res = SIMD[dtype, size](0)
    for i in range(size):
        res[i] = Scalar[dtype](i)
    return res


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        comptime zord = Byte(ord("0"))
        comptime newline = Byte(ord("\n"))
        var tot = SIMD[DType.int32, 1024](0)
        var order_split = data.find("\n\n")
        var rest = data[byte = order_split + 2 :]
        var order = data[byte=0:order_split]

        # # NEW
        var next_dct = Dict[
            StringSlice[data.origin].Immutable,
            List[StringSlice[data.origin].Immutable],
        ]()
        var prev_dct = Dict[
            StringSlice[data.origin].Immutable,
            List[StringSlice[data.origin].Immutable],
        ]()

        var prev_idx = 0

        while True:
            var lnr = order.find("\n", prev_idx)
            if lnr == -1:
                break
            var mid = order.find("|", prev_idx)
            next_dct.setdefault(order[byte=prev_idx:mid], []).append(
                order[byte = mid + 1 : lnr]
            )
            prev_dct.setdefault(order[byte = mid + 1 : lnr], []).append(
                order[byte=prev_idx:mid]
            )
            prev_idx = lnr + 1

        lines = rest.splitlines()

        @parameter
        fn calc(idx: Int):
            var line = lines[idx]
            var readed_idx = 3
            while True:
                if line.as_bytes()[readed_idx - 1] == newline:
                    # We finalize the line
                    bts = line.as_bytes()[
                        len(line) // 2 - 1 : len(line) // 2 + 1
                    ]
                    tot[idx] = (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * Int32(zord)
                        + bts[1].cast[DType.int32]()
                    )
                    break

                val = line[byte = readed_idx : readed_idx + 2]
                prev_values = line[byte=:readed_idx]

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
    fn part_2(data: StringSlice) -> Int32:
        comptime zord = ord("0")
        comptime indexes = build_indexes[DType.uint8, 32]()

        var tot = SIMD[DType.int32, 1024](0)
        var split_idx = data.find("\n\n")

        var rules = [
            (r[byte=:2], r[byte=3:])
            for r in data[byte=0:split_idx].splitlines()
        ]
        var manuals = data[byte = split_idx + 2 :].splitlines()

        @parameter
        fn calc_line(idx: Int):
            ref page = manuals[idx]
            for f, l in rules:
                var fi = page.find(f)
                var li = page.find(l)

                if fi > -1 and li > -1 and fi > li:
                    # order_manual(page, rules)
                    # var _nbr = page[len(page) // 2]
                    var _idxs = order_manual[indexes](page, rules)
                    var middle = len(page) // 2
                    var _mididx = _idxs[(middle - 1) // 3]
                    var _middle = Int(_mididx * 3) + 1
                    var _nbr = page[byte = _middle - 1 : _middle + 1]

                    bts = _nbr.as_bytes()
                    tot[idx] = (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * Int32(zord)
                        + bts[1].cast[DType.int32]()
                    )
                    break

        parallelize[calc_line](len(manuals))
        return tot.reduce_add()


fn order_manual[
    o: ImmutOrigin,
    //,
    indexes: SIMD[DType.uint8, 32],
    zeroidx: SIMD[DType.uint8, 32] = SIMD[DType.uint8, 32](0),
](
    page: StringSlice[o].Immutable,
    rules: List[Tuple[StringSlice[o].Immutable, StringSlice[o].Immutable]],
) -> SIMD[DType.uint8, 32]:
    var done = False
    var idx = indexes.copy()
    var used_rules = List[Tuple[Int, Int]]()
    for first, last in rules:
        of = page.find(first)
        ol = page.find(last)
        if of > -1 and ol > -1:
            used_rules.append((of, ol))
            fi = Int(
                idx.eq(UInt8(of // 3)).select(indexes, zeroidx).reduce_max()
            )
            li = Int(
                idx.eq(UInt8(ol // 3)).select(indexes, zeroidx).reduce_max()
            )
            if fi > li:
                idx[fi], idx[li] = idx[li], idx[fi]

    while not done:
        done = True
        for of, ol in used_rules:
            fi = Int(
                idx.eq(UInt8(of // 3)).select(indexes, zeroidx).reduce_max()
            )
            li = Int(
                idx.eq(UInt8(ol // 3)).select(indexes, zeroidx).reduce_max()
            )
            if fi > li:
                done = False
                idx[fi], idx[li] = idx[li], idx[fi]

    return idx
