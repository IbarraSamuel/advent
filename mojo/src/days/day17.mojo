from advent_utils import TensorSolution, FileTensor, ceil_pow_of_two
from collections import Dict
from utils import IndexList, Index

# Ideas
# 1. To invalidate other paths, you can store the init (x,y), end(x,y) and len(l) information
# and you can discard other paths if both start and end at the same place, but one is larger than others.
# We also need to consider direction and straight steps, to be fully compatible, because we might delete something we dont want.

alias ALL_DIRS = (Dir.UP, Dir.DOWN, Dir.LEFT, Dir.RIGHT)


fn calc_nums() -> List[Int]:
    # returns a list with uint8 from 0 - 9
    l = List[Int](capacity=10)
    for i in range(10):
        l.append(ord(str(i)))

    return l


alias NUMS = calc_nums()
alias Pos = SIMD[DType.uint8, 2]
# alias Dir = Int


@register_passable("trivial")
struct Dir:
    alias UP = 1
    alias DOWN = 2
    alias LEFT = 3
    alias RIGHT = 4
    var v: Int

    @implicit
    fn __init__(out self, v: Int):
        self.v = v

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


@value
@register_passable
struct State(KeyElement):
    var position: Int
    var direction: Dir
    var straight_steps: UInt

    fn __eq__(self, other: Self) -> Bool:
        return (
            self.position == other.position
            and self.direction == other.direction
            and self.direction == other.direction
            and self.straight_steps == other.straight_steps
        )

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)

    fn __hash__(self) -> UInt:
        return (
            self.straight_steps * 1000000
            + self.direction.v * 100000
            + self.position
            # + self.position[1] * 100
            # + self.position[0]
        )


fn move(origin: Dir, pos: Pos) -> (Pos, Pos, Pos):
    return pos, pos, pos


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        cache = Dict[State, Int](
            power_of_two_initial_capacity=ceil_pow_of_two(954288)
        )
        """each field could have 4 positions *  4 directions * 3 steps == 48"""
        """Final count will be 48 * 141 * 141 = 954288"""
        for i in range(data.bytecount()):

            @parameter
            for di in range(len(ALL_DIRS)):
                d = ALL_DIRS.get[di, Dir]()

                @parameter
                for p in range(3):
                    cache[State(position=i, direction=d, straight_steps=p)] = 0
        return 0

    @staticmethod
    fn part_2(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
