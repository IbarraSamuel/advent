from advent_utils import AdventResult
import sys


@register_passable("trivial")
struct Direction:
    alias Left = Direction(1)
    alias Right = Direction(2)
    var value: UInt8

    fn __init__(inout self, value: UInt8):
        self.value = value

    fn __init__(inout self, char: String):
        if char not in "RL" or len(char) > 1:
            print("No Valid Diretion!", char)
            sys.exit(1)

        self = Self.Left if char == "L" else Self.Right


struct Solution:
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        return 0

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        return 0
