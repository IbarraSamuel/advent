from std.collections import Dict

from advent_utils import AdventSolution


comptime COMMA = Byte(ord(","))


@always_inline("nodebug")
def hash(v: Span[Byte, _]) -> Int:
    var acc = 0
    for i in v:
        acc = ((acc + Int(i)) * 17) % 256
    return acc


def add_elems[
    o: Origin
](
    mut elems: Dict[Int, List[Tuple[String, Int]]],
    data: StringSlice[o],
    mut init: Int,
    end: Int,
):
    var elem = data[byte=init:end]
    init = end + 1
    var is_add = "=" in elem
    var sep = "=" if is_add else "-"
    var idx = elem.find(sep)
    var chr = elem[byte=:idx]
    var h = hash(chr.as_bytes())
    try:
        var n = Int(elem[byte = idx + 1 :]) if is_add else -1
        for ref it in elems.items():
            if it.key == h:
                for idx in range(len(it.value)):
                    if it.value[idx][0] == String(chr):
                        if not is_add:
                            if len(it.value) == 1:
                                _ = elems.pop(h)
                                return
                            _ = it.value.pop(idx)
                            return
                        it.value[idx][1] = n
                        return
                if not is_add:
                    return
                it.value.append((String(chr), n))
                return
        if not is_add:
            return
        var l = List[Tuple[String, Int]](capacity=10)
        l.append((String(chr), n))
        elems[h] = l^

    except:
        return


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    def part_1(data: StringSlice) -> Int:
        var lines = data.splitlines()
        var t = 0
        var acc = 0
        for v in lines[0].as_bytes():
            if v == COMMA:
                t += Int(acc)
                acc = 0
                continue
            acc = ((acc + Int(v)) * 17) % 256
        return t + acc

    @staticmethod
    def part_2(data: StringSlice) -> Int:
        var lines = data.splitlines()
        var d = lines[0]
        var elems = Dict[Int, List[Tuple[String, Int]]](
            capacity=256
        )

        var l = 0
        var v = d.find(",", l + 1)
        while v != -1:
            add_elems(elems, d, l, v)
            v = d.find(",", l + 1)
        add_elems(elems, d, l, d.byte_length())

        var tot = 0
        for it in elems.items():
            var tt = 0
            for i in range(len(it.value)):
                tt += (i + 1) * it.value[i][1]
            tot += (it.key + 1) * tt
        return tot
