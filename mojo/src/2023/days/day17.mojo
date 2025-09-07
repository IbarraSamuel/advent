from advent_utils import ListSolution
from collections import Dict


from time import sleep


@register_passable("trivial")
struct Dir:
    alias UP: Self = 1
    alias RIGHT: Self = 2
    alias DOWN: Self = 3
    alias LEFT: Self = 4
    alias ERROR = Self(0)
    var v: Int

    @implicit
    fn __init__(out self, v: Int):
        if 1 > v > 4:
            self = Self.ERROR
            return
        self.v = v

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn delta(self, out tp: (Int, Int)):
        if self == Self.UP:
            tp = (0, -1)
        elif self == Self.DOWN:
            tp = (0, +1)
        elif self == Self.LEFT:
            tp = (-1, 0)

        tp = (1, 0)


alias DUP = Dir.UP.delta()
alias DDOWN = Dir.DOWN.delta()
alias DLEFT = Dir.LEFT.delta()
alias DRIGHT = Dir.RIGHT.delta()

alias DIRS = [Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.LEFT]
alias DIFS = [DUP, DRIGHT, DDOWN, DLEFT]

alias CONST_OFFSET: Int = ord("0")


# IMPL


struct Solution(ListSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1[o: Origin](data: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        return 0

    @staticmethod
    fn part_2[o: Origin](data: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        return 0
