from advent_utils import TensorSolution, FileTensor, ceil_pow_of_two
from collections import Dict
from utils import IndexList, Index

# Ideas
# 1. To invalidate other paths, you can store the init (x,y), end(x,y) and len(l) information
# and you can discard other paths if both start and end at the same place, but one is larger than others.
# We also need to consider direction and straight steps, to be fully compatible, because we might delete something we dont want.


@register_passable("trivial")
struct Dir:
    alias UP: Self = 1
    alias DOWN: Self = 2
    alias LEFT: Self = 3
    alias RIGHT: Self = 4
    var v: Int

    @implicit
    fn __init__(out self, v: Int):
        self.v = v

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


alias ALL_DIRS = (Dir.UP, Dir.DOWN, Dir.LEFT, Dir.RIGHT)


fn calc_nums() -> List[Int]:
    # returns a list with uint8 from 0 - 9
    l = List[Int](capacity=10)
    for i in range(10):
        l.append(ord(str(i)))

    return l


alias NUMS = calc_nums()
alias Pos = SIMD[DType.uint8, 2]


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


alias DUP: Pos = Pos(-1, 0)
alias DDOWN: Pos = Pos(1, 0)
alias DLEFT: Pos = Pos(0, -1)
alias DRIGHT: Pos = Pos(0, 1)

alias DIRS = List[Dir, True](Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.LEFT)
alias DIFS = List[Pos, True](DUP, DRIGHT, DDOWN, DLEFT)


fn indexof(dir: Dir) -> Int:
    return (
        0 * (dir == Dir.UP)
        + 1 * (dir == Dir.DOWN)
        + 2 * (dir == Dir.LEFT)
        + 3 * (dir == Dir.RIGHT)
    )


fn move_pos(dir: Dir, pos: Pos) -> Pos:
    d = indexof(dir)
    df = DIFS[d]
    return pos + df


alias Step = (Dir, Pos, Int)


fn move(step: Step) -> (Step, Step, Step):
    dir, pos, forward = step
    s1, s2 = move_sides(step)
    sx = dir, move_pos(dir, pos), forward + 1
    return s1, sx, s2


fn move_sides(step: Step) -> (Step, Step):
    dir, pos, _ = step
    d = indexof(dir)
    df1, df2 = DIFS[d - 1], DIFS[d + 1]
    d1, d2 = DIRS[d - 1], DIRS[d + 1]
    return (d1, pos + df1, 0), (d2, pos + df2, 0)


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        _cache = Dict[State, Int](
            # power_of_two_initial_capacity=ceil_pow_of_two(954288)
        )
        """each field could have 4 positions *  4 directions * 3 steps == 48"""
        """Final count will be 48 * 141 * 141 = 954288"""

        pos = Pos(0, 0)
        d1, d2 = Dir.DOWN, Dir.RIGHT
        steps = 0

        queue = List[Step]((d1, pos, steps), (d2, pos, steps))

        for tp in queue:
            _, pos, forward = tp[]
            if forward == 2:
                st1, st2 = move_sides(tp[])
                queue.append(st1)
                queue.append(st2)
                continue

            st1, st2, st3 = move(tp[])
            queue.append(st1)
            queue.append(st2)
            queue.append(st3)

        # @parameter
        # for di in range(len(ALL_DIRS)):
        #     d = ALL_DIRS.get[di, Dir]()

        # @parameter
        # for p in range(3):
        #     cache[State(position=i, direction=d, straight_steps=p)] = 0
        return 0

    @staticmethod
    fn part_2(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
