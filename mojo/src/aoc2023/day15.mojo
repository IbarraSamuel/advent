from std.collections import Dict
from std.memory import Span

from advent_utils import AdventSolution


comptime COMMA = Byte(ord(","))


@always_inline("nodebug")
def hash(v: Span[Byte, _]) -> Int:
    acc = 0
    for i in v:
        acc = ((acc + Int(i)) * 17) % 256
    return acc


def add_elems[
    o: ImmutOrigin
](
    mut elems: Dict[Int, List[Tuple[StringSlice[o], Int]]],
    data: StringSlice[o],
    mut init: Int,
    end: Int,
):
    elem, init = data[byte=init:end], end + 1
    is_add = "=" in elem
    sep = "=" if is_add else "-"
    idx = elem.find(sep)
    chr = elem[byte=:idx]
    h = hash(chr.as_bytes())
    try:
        n = Int(elem[byte = idx + 1 :]) if is_add else -1
        for ref it in elems.items():
            if it.key == h:
                for idx in range(len(it.value)):
                    if it.value[idx][0] == chr:
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
                it.value.append((chr, n))
                return
        if not is_add:
            return
        l = List[Tuple[StringSlice[o], Int]](capacity=10)
        l.append((chr, n))
        elems[h] = l^

    except:
        return


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    def part_1(data: StringSlice) -> Int:
        var lines = data.splitlines()
        t = 0
        acc = 0
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
        elems = Dict[Int, List[Tuple[StringSlice[data.origin].Immutable, Int]]](
            capacity=256
        )

        l = 0
        while (v := d.find(",", l + 1)) != -1:
            add_elems(elems, d, l, v)
        add_elems(elems, d, l, len(d))

        tot = 0
        for it in elems.items():
            tt = 0
            for i in range(len(it.value)):
                tt += (i + 1) * it.value[i][1]
            tot += (it.key + 1) * tt
        return tot
