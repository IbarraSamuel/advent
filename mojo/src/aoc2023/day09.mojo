import std.os as os
from std.collections import Optional

from advent_utils import AdventSolution

comptime Size = 32
comptime Line = SIMD[DType.int64, Size]


def calc_prev_and_next(var value: Line, last: Int) -> Tuple[Int64, Int64]:
    var idx, frst, lst = 0, Int64(0), Int64(0)
    while not (value == 0):
        frst = value[0] - frst
        lst += value[last - 1 - idx]
        value = value.shift_left[1]() - value
        value[last - 1 - idx] = 0
        idx += 1

    if not idx % 2:
        frst = -frst

    return frst, lst


def create_line(v: StringSlice) -> Tuple[Line, Int]:
    var values = v.split()
    var line = Line(0)

    try:
        comptime for i in range(21):
            if i >= len(values):
                break
            line[i] = Int64(Int(values[i]))
    except:
        os.abort("bad bad on create line")
        pass

    return (line, len(values))


struct Solution(AdventSolution):
    comptime T = Int64

    @staticmethod
    def part_1(data: StringSlice) -> Int64:
        var lines = data.splitlines()
        var tot = Int64(0)
        for idx in range(len(lines)):
            var line, last = create_line(lines[idx])
            var _, l = calc_prev_and_next(line, last)
            tot += l

        return tot

    @staticmethod
    def part_2(data: StringSlice) -> Int64:
        var lines = data.splitlines()
        var tot = Int64(0)
        for idx in range(len(lines)):
            var line, last = create_line(lines[idx])
            var f, _ = calc_prev_and_next(line, last)
            tot += f

        return tot
