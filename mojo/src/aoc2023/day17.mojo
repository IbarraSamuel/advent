from advent_utils import AdventSolution
from collections import Dict


from time import sleep


@register_passable("trivial")
struct Dir:
    comptime UP: Self = 1
    comptime RIGHT: Self = 2
    comptime DOWN: Self = 3
    comptime LEFT: Self = 4
    comptime ERROR = Self(0)
    var v: Int

    @implicit
    fn __init__(out self, v: Int):
        if 1 > v > 4:
            self = Self.ERROR
            return
        self.v = v

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn delta(self, out tp: Tuple[Int, Int]):
        if self == Self.UP:
            tp = (0, -1)
        elif self == Self.DOWN:
            tp = (0, +1)
        elif self == Self.LEFT:
            tp = (-1, 0)

        tp = (1, 0)


comptime DUP = Dir.UP.delta()
comptime DDOWN = Dir.DOWN.delta()
comptime DLEFT = Dir.LEFT.delta()
comptime DRIGHT = Dir.RIGHT.delta()

comptime DIRS = [Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.LEFT]
comptime DIFS = [DUP, DRIGHT, DDOWN, DLEFT]

comptime CONST_OFFSET: Int = ord("0")


# IMPL


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        return 0

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        return 0
