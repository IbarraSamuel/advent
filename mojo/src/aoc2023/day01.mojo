from advent_utils import AdventSolution
from std.collections import Dict, Optional
from std.builtin.globals import global_constant

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


struct Solution(AdventSolution):
    @staticmethod
    def part_1(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = Int32(0)
        for idx in range(len(lines)):
            # for idx in range(lines.size):
            var f, l = first_numeric(lines[idx])
            total += Int32(f * 10 + l)

        return total

    @staticmethod
    def part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = Int32(0)
        for idx in range(len(lines)):
            total += Int32(line_value(lines[idx]))
        return total


def part_1(data: StringSlice) -> Int32:
    var lines = data.splitlines()
    var total = Int32(0)
    for idx in range(len(lines)):
        # for idx in range(lines.size):
        var f, l = first_numeric(lines[idx])
        total += Int32(f * 10 + l)

    return total


def part_2(data: StringSlice) -> Int32:
    var lines = data.splitlines()
    var total = Int32(0)
    for idx in range(len(lines)):
        total += Int32(line_value(lines[idx]))
    return total


@always_inline("nodebug")
def to_int(v: StringSlice, mut o: Int):
    try:
        o = Int(v)
    except:
        pass


def first_numeric(line: StringSlice) -> Tuple[Int, Int]:
    var pos, end = 0, line.byte_length() - 1
    var fval, lval = 0, 0

    while pos <= end:
        if fval == 0:
            to_int(line[byte = pos : pos + 1], fval)
        if not lval:
            to_int(line[byte = end - pos : end - pos + 1], lval)

        if not fval or not lval:
            pos += 1
        elif fval and lval:
            return fval, lval

    return fval, lval


def line_value(line: StringSlice) -> Int:
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
