from advent_utils import AdventSolution, AdventResult
from collections import Dict, Optional
from collections.string import atol


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(input: List[String]) -> AdventResult:
        var total = 0
        for line in input:
            total += calc[F=first_numeric](line[])

        return total

    @staticmethod
    fn part_2(input: List[String]) -> AdventResult:
        var mapper = Dict[String, Int]()
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

        var total = 0
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


fn line_value(line: String, mapper: Dict[String, Int]) -> Int:
    var first_k: Optional[String] = None
    var first: Int = -1
    var last_k: Optional[String] = None
    var last: Int = -1

    for k in mapper:
        var mn = line.find(k[])
        var mx = line.rfind(k[])

        if first == -1 or mn != -1 and mn < first:
            first_k, first = Optional(k[]), mn

        if last == -1 or mx != -1 and mx > last:
            last_k, last = Optional(k[]), mx

    return mapper.get(first_k.value(), 0) * 10 + mapper.get(last_k.value(), 0)


@always_inline
fn calc[F: fn[IntLiteral] (String) -> Int](line: String) -> Int:
    return F[+1](line) * 10 + F[-1](line)
