from advent_utils import SIMDResult, ListSolution
from collections import Dict, Optional
from algorithm.functional import parallelize

alias MapList = [
    (StaticString("one"), 1),
    (StaticString("two"), 2),
    (StaticString("three"), 3),
    (StaticString("four"), 4),
    (StaticString("five"), 5),
    (StaticString("six"), 6),
    (StaticString("seven"), 7),
    (StaticString("eight"), 8),
    (StaticString("nine"), 9),
    (StaticString("1"), 1),
    (StaticString("2"), 2),
    (StaticString("3"), 3),
    (StaticString("4"), 4),
    (StaticString("5"), 5),
    (StaticString("6"), 6),
    (StaticString("7"), 7),
    (StaticString("8"), 8),
    (StaticString("9"), 9),
]


struct Solution(ListSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        var total = SIMDResult(0)

        @parameter
        fn calc_line(idx: Int):
            # for idx in range(lines.size):
            f, l = first_numeric(lines[idx])
            total[idx] = f * 10 + l

        parallelize[calc_line](len(lines))
        return total.reduce_add()

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        var total = SIMDResult(0)

        @parameter
        fn calc_line(idx: Int):
            total[idx] = line_value(lines[idx])

        parallelize[calc_line](len(lines))
        return total.reduce_add()


@always_inline("nodebug")
fn to_int(v: String, mut o: Int):
    try:
        o = Int(v)
    except:
        pass


fn first_numeric(line: String) -> (Int, Int):
    pos, end = 0, len(line) - 1
    fval, lval = 0, 0

    while pos <= end:
        if fval == 0:
            to_int(line[pos], fval)
        if not lval:
            to_int(line[end - pos], lval)

        if not fval or not lval:
            pos += 1
        elif fval and lval:
            return fval, lval

    return fval, lval


fn line_value(line: String) -> Int:
    var first_v = 0
    var first_idx: Int = -1
    var last_v = 0
    var last_idx: Int = -1

    @parameter
    for idx in range(len(MapList)):
        k, v = MapList.get[idx, (StaticString, Int)]()
        var mn = line.find(k)
        var mx = line.rfind(k)

        if first_idx == -1 or mn != -1 and mn < first_idx:
            first_v, first_idx = v, mn

        if last_idx == -1 or mx != -1 and mx > last_idx:
            last_v, last_idx = v, mx

    return first_v * 10 + last_v
