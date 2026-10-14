from std.algorithm.functional import vectorize
from std.collections import Set
from std.os import abort
from std.math import log2
from std.memory.unsafe import pack_bits

from advent_utils import AdventSolution


def build_indexes[dtype: DType, size: Int]() -> SIMD[dtype, size]:
    var res = SIMD[dtype, size](0)
    for i in range(size):
        res[i] = Scalar[dtype](i)
    return res


struct Solution(AdventSolution):
    @staticmethod
    def part_1(data: StringSlice) -> Int32:
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

        var lines = rest.splitlines()

        def calc[
            v: Int
        ](idx: Int) {imm lines, imm next_dct, imm prev_dct, mut tot}:
            var line = lines[idx]
            var readed_idx = 3
            while True:
                if readed_idx >= line.byte_length():
                    # We finalize the line
                    var bts = line.as_bytes()[
                        line.byte_length() // 2
                        - 1 : line.byte_length() // 2
                        + 1
                    ]
                    tot[idx] = (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * Int32(zord)
                        + bts[1].cast[DType.int32]()
                    )
                    break

                var val = line[byte = readed_idx : readed_idx + 2]
                var prev_values = line[byte=:readed_idx]

                # if val in prev_dct:
                var res = prev_dct.get(val)
                var found = False
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

        vectorize[1](len(lines), calc)
        return tot.reduce_add()

    @staticmethod
    def part_2(data: StringSlice) -> Int32:
        comptime zord = ord("0")
        comptime indexes = build_indexes[DType.uint8, 32]()

        var tot = SIMD[DType.int32, 1024](0)
        var split_idx = data.find("\n\n")

        var rules = [
            (r[byte=:2], r[byte=3:])
            for r in data[byte=0:split_idx].splitlines()
        ]
        var manuals = data[byte = split_idx + 2 :].splitlines()

        def calc_line[v: Int](idx: Int) {imm manuals, imm rules, mut tot}:
            ref page = manuals[idx]
            for f, l in rules:
                var fi = page.find(f)
                var li = page.find(l)

                if fi > -1 and li > -1 and fi > li:
                    # order_manual(page, rules)
                    # var _nbr = page[len(page) // 2]
                    var _idxs = order_manual[indexes](page, rules)
                    var middle = page.byte_length() // 2
                    var _mididx = _idxs[(middle - 1) // 3]
                    var _middle = Int(_mididx * 3) + 1
                    var _nbr = page[byte = _middle - 1 : _middle + 1]

                    var bts = _nbr.as_bytes()
                    tot[idx] = (
                        10 * bts[0].cast[DType.int32]()
                        - 11 * Int32(zord)
                        + bts[1].cast[DType.int32]()
                    )
                    break

        vectorize[1](len(manuals), calc_line)
        return tot.reduce_add()


def order_manual[
    o: ImmOrigin,
    //,
    indexes: SIMD[DType.uint8, 32],
    zeroidx: SIMD[DType.uint8, 32] = SIMD[DType.uint8, 32](0),
](
    page: StringSlice[o],
    rules: List[Tuple[StringSlice[o], StringSlice[o]]],
) -> SIMD[DType.uint8, 32]:
    var owned_page = String(page)
    var done = False
    var idx = indexes.copy()
    var used_rules = List[Tuple[Int, Int]]()
    for first, last in rules:
        var of = owned_page.find(first)
        var ol = owned_page.find(last)
        if of > -1 and ol > -1:
            used_rules.append((of, ol))
            var fi = Int(
                idx.eq(UInt8(of // 3)).select(indexes, zeroidx).reduce_max()
            )
            var li = Int(
                idx.eq(UInt8(ol // 3)).select(indexes, zeroidx).reduce_max()
            )
            if fi > li:
                idx[fi], idx[li] = idx[li], idx[fi]

    while not done:
        done = True
        for of, ol in used_rules:
            var fi = Int(
                idx.eq(UInt8(of // 3)).select(indexes, zeroidx).reduce_max()
            )
            var li = Int(
                idx.eq(UInt8(ol // 3)).select(indexes, zeroidx).reduce_max()
            )
            if fi > li:
                done = False
                idx[fi], idx[li] = idx[li], idx[fi]

    return idx
