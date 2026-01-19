from collections.string import StringSlice
from collections.optional import OptionalReg
from algorithm import parallelize
from advent_utils import AdventSolution


fn is_mirror[o: Origin](values: Span[StringSlice[o]]) -> OptionalReg[Int]:
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


fn is_mirror(values: Span[String]) -> OptionalReg[Int]:
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


fn almost_a_mirror[o: Origin](values: Span[StringSlice[o]]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        mn = min(i, len(values) - i)
        p1 = values[i - mn : i]
        p2 = values[i : i + mn]
        dif = 0
        for i in range(mn):
            if p1[i] != p2[len(p2) - i - 1]:
                for j in range(len(p1[i])):
                    if p1[i].as_bytes()[j] != p2[len(p2) - i - 1].as_bytes()[j]:
                        dif += 1
        if dif == 1:
            return i
    return None


fn almost_a_mirror(values: Span[String]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        mn = min(i, len(values) - i)
        p1 = values[i - mn : i]
        p2 = values[i : i + mn]
        dif = 0
        for i in range(mn):
            if p1[i] != p2[len(p2) - i - 1]:
                for j in range(len(p1[i])):
                    if p1[i].as_bytes()[j] != p2[len(p2) - i - 1].as_bytes()[j]:
                        dif += 1
        if dif == 1:
            return i
    return None


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        total = SIMD[DType.int32, 128]()
        spaces = [-1]
        var i = 0
        while i < len(data):
            idx = data.find("\n\n", i + 1)
            if idx == -1:
                spaces.append(len(data))
                break
            i = idx
            spaces.append(idx + 1)

        @parameter
        fn calc_line(i: Int):
            group = data[spaces[i] + 1 : spaces[i + 1]].splitlines()

            place = is_mirror(group)
            if place:
                total[i] = place.value() * 100
                return

            new_len = group[0].byte_length()
            new_group = List[String](capacity=new_len)
            for j in range(new_len):
                new_str = String(capacity=len(group))
                for k in range(len(group)):
                    new_str.write(group[k][j : j + 1])
                new_group.append(new_str)

            total[i] = is_mirror(new_group).value()

        parallelize[calc_line](len(spaces) - 1)
        return total.reduce_add()

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        total = SIMD[DType.int32, 128]()
        # total = Int32()
        spaces = [-1]
        for i in range(len(lines)):
            if not lines[i]:
                spaces.append(i)
        spaces.append(len(lines))

        # for i in range(spaces.size - 1):
        @parameter
        fn calc_line(i: Int):
            group = lines[spaces[i] + 1 : spaces[i + 1]]
            place = almost_a_mirror(group)
            if place:
                # total += place.value() * 100
                total[i] = place.value() * 100
                return

            new_len = group[0].byte_length()
            new_group = List[String](capacity=new_len)
            for j in range(new_len):
                new_str = String(capacity=len(group))
                for k in range(len(group)):
                    new_str.write(group[k][j : j + 1])
                new_group.append(new_str)

            # total += almost_a_mirror(new_group).value()
            total[i] = almost_a_mirror(new_group).value()

        parallelize[calc_line](len(spaces) - 1)

        return total.reduce_add()
