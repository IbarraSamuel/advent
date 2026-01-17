from advent_utils import AdventSolution
from collections import Dict, Optional
from algorithm.functional import parallelize
from builtin.globals import global_constant

comptime MapList = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
    "1": 1,
    "2": 2,
    "3": 3,
    "4": 4,
    "5": 5,
    "6": 6,
    "7": 7,
    "8": 8,
    "9": 9,
}

# comptime NUM_MAP: List[(StaticString, Int)] = [
#     (StaticString("two"), 2),
#     (StaticString("three"), 3),
#     (StaticString("four"), 4),
#     (StaticString("five"), 5),
#     (StaticString("six"), 6),
#     (StaticString("seven"), 7),
#     (StaticString("eight"), 8),
#     (StaticString("nine"), 9),
#     (StaticString("1"), 1),
#     (StaticString("2"), 2),
#     (StaticString("3"), 3),
#     (StaticString("4"), 4),
#     (StaticString("5"), 5),
#     (StaticString("6"), 6),
#     (StaticString("7"), 7),
#     (StaticString("8"), 8),
#     (StaticString("9"), 9),
# ]


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = SIMD[DType.int32, 1024](0)

        @parameter
        fn calc_line(idx: Int):
            # for idx in range(lines.size):
            f, l = first_numeric(lines[idx])
            total[idx] = f * 10 + l

        parallelize[calc_line](len(lines))
        return total.reduce_add()

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = SIMD[DType.int32, 1024](0)

        @parameter
        fn calc_line(idx: Int):
            total[idx] = line_value(lines[idx])

        parallelize[calc_line](len(lines))
        return total.reduce_add()


@always_inline("nodebug")
fn to_int(v: StringSlice, mut o: Int):
    try:
        o = Int(v)
    except:
        pass


fn first_numeric(line: StringSlice) -> Tuple[Int, Int]:
    pos, end = 0, len(line) - 1
    fval, lval = 0, 0

    while pos <= end:
        if fval == 0:
            to_int(line[pos : pos + 1], fval)
        if not lval:
            to_int(line[end - pos : end - pos + 1], lval)

        if not fval or not lval:
            pos += 1
        elif fval and lval:
            return fval, lval

    return fval, lval


fn line_value(line: StringSlice) -> Int:
    var first_v = 0
    var first_idx: Int = -1
    var last_v = 0
    var last_idx: Int = -1

    # @parameter
    # for i in range(len(MapList)):
    # ref map_list = global_constant[MapList]()
    ref map_list = materialize[MapList]()
    for kv in map_list.items():
        var key = kv.key
        var value = kv.value
        # comptime k = MapList[i][0]
        # comptime v = MapList[i][1]
        var mn = line.find(key)
        var mx = line.rfind(key)

        if first_idx == -1 or mn != -1 and mn < first_idx:
            first_v, first_idx = value, mn

        if last_idx == -1 or mx != -1 and mx > last_idx:
            last_v, last_idx = value, mx

    return first_v * 10 + last_v
