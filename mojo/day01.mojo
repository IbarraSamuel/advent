from advent_utils import read_input, AdventSolution, AdventResultType
from builtin.string import atol
from collections import Optional


struct Solution(AdventSolution):
    alias T = Int

    @staticmethod
    fn day_1[T: AdventResultType = Self.T](input: List[String]) -> T:
        var total: Self.T = 0
        for line in input:
            total += calc[F=first_numeric](line[])

        return total

    @staticmethod
    fn day_2[T: AdventResultType = Self.T](input: List[String]) -> T:
        var mapper = Dict[StringLiteral, Int]()
        mapper["one"] = 1
        mapper["two"] = 2
        mapper["three"] = 3
        mapper["four"] = 4
        mapper["five"] = 5
        mapper["six"] = 6
        mapper["seven"] = 7
        mapper["eight"] = 8
        mapper["nine"] = 9
        mapper["1"] = 1
        mapper["2"] = 2
        mapper["3"] = 3
        mapper["4"] = 4
        mapper["5"] = 5
        mapper["6"] = 6
        mapper["7"] = 7
        mapper["8"] = 8
        mapper["9"] = 9

        var total: Self.T = 0
        for line in input:
            total += line_value(line[], mapper)

        return total


fn first_numeric[accum: IntLiteral](line: String) -> Int:
    var init = len(line) - 1 if accum < 1 else 0
    var end = -1 if accum < 1 else len(line)

    while init != end:
        try:
            return atol(line[init])
        except:
            init += accum
    return 0


fn line_value(line: String, mapper: Dict[StringLiteral, Int]) -> Int:
    var found_items = List[Tuple[StringLiteral, Int]]()
    for k in mapper:
        var idx = line.find(k[])
        if idx != -1:
            found_items.append((k[], idx))

    var min_val = Tuple("", len(line))
    var max_val = Tuple("", -1)
    for it in found_items:
        if min_val.get[1, Int]() > it[].get[1, Int]():
            min_val = it[]
        if max_val.get[1, Int]() < it[].get[1, Int]():
            max_val = it[]

    var first = mapper.find(min_val.get[0, StringLiteral]()).value()
    var last = mapper.find(max_val.get[0, StringLiteral]()).value()
    return first * 10 + last


@always_inline
fn calc[F: fn[IntLiteral] (String) -> Int](line: String) -> Int:
    return F[+1](line) * 10 + F[-1](line)
