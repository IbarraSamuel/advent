from collections.string import StringSlice
from collections.optional import OptionalReg
from algorithm import parallelize
from advent_utils import ListSolution


fn is_mirror[o: Origin](values: List[StringSlice[o]]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        mn = min(i, len(values) - i)
        f = values[i - mn : i]
        l = values[i : i + mn]
        l.reverse()
        if f == l:
            return i
    return None


fn is_mirror(values: List[String]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        mn = min(i, len(values) - i)
        f = values[i - mn : i]
        l = values[i : i + mn]
        l.reverse()
        if f == l:
            return i
    return None


fn almost_a_mirror[o: Origin](values: List[StringSlice[o]]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        mn = min(i, len(values) - i)
        p1 = values[i - mn : i]
        p2 = values[i : i + mn]
        p2.reverse()
        dif = 0
        for i in range(mn):
            if p1[i] != p2[i]:
                for j in range(len(p1[i])):
                    if p1[i][j] != p2[i][j]:
                        dif += 1
        if dif == 1:
            return i
    return None


fn almost_a_mirror(values: List[String]) -> OptionalReg[Int]:
    for i in range(1, len(values)):
        mn = min(i, len(values) - i)
        p1 = values[i - mn : i]
        p2 = values[i : i + mn]
        p2.reverse()
        dif = 0
        for i in range(mn):
            if p1[i] != p2[i]:
                for j in range(len(p1[i])):
                    if p1[i][j] != p2[i][j]:
                        dif += 1
        if dif == 1:
            return i
    return None


struct Solution(ListSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1[o: Origin](lines: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        total = SIMD[Self.dtype, 128]()
        # total = Scalar[Self.dtype]()
        spaces = List[Int](-1)
        for i in range(len(lines)):
            if not lines[i]:
                spaces.append(i)
        spaces.append(len(lines))

        @parameter
        fn calc_line(i: Int):
            # for i in range(spaces.size - 1):
            group = lines[spaces[i] + 1 : spaces[i + 1]]
            place = is_mirror(group)
            if place:
                # total += place.value() * 100
                total[i] = place.value() * 100
                return

            new_len = group[0].byte_length()
            new_group = List[String](capacity=new_len)
            for j in range(new_len):
                new_str = String(capacity=len(group))
                for k in range(len(group)):
                    new_str.write(group[k][j])
                new_group.append(new_str)

            # total += is_mirror(new_group).value()
            total[i] = is_mirror(new_group).value()

        parallelize[calc_line](len(spaces) - 1)
        return total.reduce_add()

    @staticmethod
    fn part_2[o: Origin](lines: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        total = SIMD[Self.dtype, 128]()
        # total = Scalar[Self.dtype]()
        spaces = List[Int](-1)
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
                    new_str.write(group[k][j])
                new_group.append(new_str)

            # total += almost_a_mirror(new_group).value()
            total[i] = almost_a_mirror(new_group).value()

        parallelize[calc_line](len(spaces) - 1)

        return total.reduce_add()


fn calc_line(line: String) -> Int32:
    return len(line)
