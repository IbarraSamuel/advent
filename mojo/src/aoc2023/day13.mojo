from std.collections.string import StringSlice
from std.collections.optional import OptionalReg
from std.algorithm.functional import vectorize
from advent_utils import AdventSolution


def is_mirror[o: Origin](values: Span[StringSlice[o], _]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        # the span of the comparisson
        var sp = min(i, len(values) - i)
        var f = values[i - sp : i]
        var l = values[i : i + sp]
        var is_eq = True
        for ii in range(sp):
            if f[ii] != l[sp - ii - 1]:
                is_eq = False
                break

        if is_eq:
            return i
    return None


def is_mirror(values: Span[String, _]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        # the span of the comparisson
        var sp = min(i, len(values) - i)
        var f = values[i - sp : i]
        var l = values[i : i + sp]
        var is_eq = True
        for ii in range(sp):
            if f[ii] != l[sp - ii - 1]:
                is_eq = False
                break

        if is_eq:
            return i
    return None


def almost_a_mirror[
    o: Origin
](values: Span[StringSlice[o], _]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        var mn = min(i, len(values) - i)
        var p1 = values[i - mn : i]
        var p2 = values[i : i + mn]
        var dif = 0
        for ii in range(mn):
            if p1[ii] != p2[len(p2) - ii - 1]:
                for j in range(p1[ii].byte_length()):
                    if p1[ii].as_bytes()[j] != p2[len(p2) - ii - 1].as_bytes()[j]:
                        dif += 1
        if dif == 1:
            return i
    return None


def almost_a_mirror(values: Span[String, _]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        var mn = min(i, len(values) - i)
        var p1 = values[i - mn : i]
        var p2 = values[i : i + mn]
        var dif = 0
        for ii in range(mn):
            if p1[ii] != p2[len(p2) - ii - 1]:
                for j in range(p1[ii].byte_length()):
                    if p1[ii].as_bytes()[j] != p2[len(p2) - ii - 1].as_bytes()[j]:
                        dif += 1
        if dif == 1:
            return i
    return None


struct Solution(AdventSolution):
    @staticmethod
    def part_1(data: StringSlice) -> Int32:
        var total = SIMD[DType.int32, 128]()
        var spaces = List[Int]()
        spaces.append(-1)
        var i = 0
        while i < data.byte_length():
            var idx = data.find("\n\n", i + 1)
            if idx == -1:
                spaces.append(data.byte_length())
                break
            i = idx
            spaces.append(idx + 1)

        def calc_line[v: Int](i: Int) {imm data, imm spaces, mut total}:
            var group = data[byte = spaces[i] + 1 : spaces[i + 1]].splitlines()

            var place = is_mirror(group)
            if place:
                total[i] = Int32(place.value()) * 100
                return

            var new_len = group[0].byte_length()
            var new_group = List[String](capacity=new_len)
            for j in range(new_len):
                var new_str = String()
                for k in range(len(group)):
                    new_str.write(group[k][byte = j : j + 1])
                new_group.append(new_str)

            total[i] = Int32(is_mirror(new_group).value())

        vectorize[1](len(spaces) - 1, calc_line)
        return total.reduce_add()

    @staticmethod
    def part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = SIMD[DType.int32, 128]()
        # total = Int32()
        var spaces = List[Int]()
        spaces.append(-1)
        for line_idx in range(len(lines)):
            if not lines[line_idx]:
                spaces.append(line_idx)
        spaces.append(len(lines))

        # for i in range(spaces.size - 1):
        def calc_line[v: Int](i: Int) {imm lines, imm spaces, mut total}:
            var group = lines[spaces[i] + 1 : spaces[i + 1]]
            var place = almost_a_mirror(group)
            if place:
                # total += place.value() * 100
                total[i] = Int32(place.value()) * 100
                return

            var new_len = group[0].byte_length()
            var new_group = List[String](capacity=new_len)
            for j in range(new_len):
                var new_str = String()
                for k in range(len(group)):
                    new_str.write(group[k][byte = j : j + 1])
                new_group.append(new_str)

            # total += almost_a_mirror(new_group).value()
            total[i] = Int32(almost_a_mirror(new_group).value())

        vectorize[1](len(spaces) - 1, calc_line)

        return total.reduce_add()
