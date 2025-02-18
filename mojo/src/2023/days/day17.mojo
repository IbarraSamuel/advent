from advent_utils import TensorSolution, FileTensor, ceil_pow_of_two
from collections import Dict, Set
from utils import IndexList, Index
import os

# Ideas
# 1. To invalidate other paths, you can store the init (x,y), end(x,y) and len(l) information
# and you can discard other paths if both start and end at the same place, but one is larger than others.
# We also need to consider direction and straight steps, to be fully compatible, because we might delete something we dont want.


@register_passable("trivial")
struct Dir(Writable):
    alias UP: Self = 1
    alias DOWN: Self = 2
    alias LEFT: Self = 3
    alias RIGHT: Self = 4
    var v: Int

    @implicit
    fn __init__(out self, v: Int):
        if 1 > v > 4:
            os.abort("not valid dir")
        self.v = v

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)

    fn write_to[W: Writer](self, mut writer: W):
        return writer.write(
            "UP" if self
            == Self.UP else "DOWN" if self
            == Self.DOWN else "LEFT" if self
            == Self.LEFT else "RIGHT"
        )


alias ALL_DIRS = (Dir.UP, Dir.DOWN, Dir.LEFT, Dir.RIGHT)


fn calc_nums() -> List[Int]:
    # returns a list with uint8 from 0 - 9
    l = List[Int](capacity=10)
    for i in range(10):
        l.append(ord(String(i)))

    return l


alias NUMS = calc_nums()
alias Pos = IndexList[2]


@value
struct HStep(KeyElement):
    var step: Step

    @implicit
    fn __init__(out self, step: Step):
        self.step = step

    fn __eq__(self, other: Self) -> Bool:
        sd, sp, ss = self.step
        od, op, os = other.step
        return sd == od and sp == op and ss == os

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)

    fn __hash__(self) -> UInt:
        return (
            self.step[2] * 1000000
            + self.step[0].v * 100000
            + Int(self.step[1][0] * 100)
            + Int(self.step[1][1])
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
        + 1 * (dir == Dir.RIGHT)
        + 2 * (dir == Dir.DOWN)
        + 3 * (dir == Dir.LEFT)
    )


fn move_pos(dir: Dir, pos: Pos) -> Pos:
    d = indexof(dir)
    df = DIFS[d]
    try:
        print("moving from {} to {}".format(String(pos), String(pos + df)))
    except:
        pass
    return pos + df


alias Step = (Dir, Pos, Int)


fn print_step(s: Step):
    dir, st, forw = s
    print(
        "Moving to Dir:",
        dir,
        "in position:",
        st,
        "and going forward by:",
        forw,
    )


"""Direction, Position, Steps"""


fn move(step: Step) -> (Step, Step, Step):
    dir, pos, forward = step
    s1, s2 = move_sides(step)
    sx = dir, move_pos(dir, pos), forward + 1
    print_step(sx)
    print()
    return s1, sx, s2


fn move_sides(step: Step) -> (Step, Step):
    dir, pos, _ = step
    d = indexof(dir)
    left, right = d - 1 if d >= 1 else 3, d + 1 if d <= 2 else 0
    df1, df2 = DIFS[left], DIFS[right]
    d1, d2 = DIRS[left], DIRS[right]
    s1, s2 = (d1, pos + df1, 0), (d2, pos + df2, 0)
    print_step(s1)
    print_step(s2)
    return s1, s2


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        """Each field could have 4 positions *  4 directions * 3 steps == 48."""
        """Final count will be 48 * 141 * 141 = 954288"""

        pos = Pos(0, 0)
        sp = data.shape()
        last = Pos(sp[0] - 1, sp[1] - 1)
        d1, d2 = Dir.DOWN, Dir.RIGHT
        steps, count = 0, 0

        queue = List[Step]((d1, pos, steps), (d2, pos, steps))
        counts = Dict[HStep, Int]()
        readed = Set[HStep]()
        counts[(d1, pos, steps)] = count
        counts[(d2, pos, steps)] = count

        for tp in queue:
            _, pos, forward = tp[]
            count = counts[tp[]]
            # Its already calculated or it's last position or position oob
            if (
                tp[] in readed
                or pos == last
                or pos[0] > last[0]
                or pos[1] > last[1]
            ):
                continue

            if forward == 2:  # Need to change direction
                st1, st2 = move_sides(tp[])
                print()
                counts[st1] = count + 1
                counts[st2] = count + 1
                queue.append(st1)
                queue.append(st2)
                readed.add(tp[])
                continue

            st1, st2, st3 = move(tp[])
            counts[st1] = count + 1
            counts[st2] = count + 1
            counts[st3] = count + 1
            queue.append(st1)
            queue.append(st2)
            queue.append(st3)
            readed.add(tp[])

        mn = Int.MAX
        for k in counts.items():
            if k[].key.step[1] == last:
                mn = min(mn, k[].value)

        print("Done!!!!! is valid?:", mn != Int.MAX)

        # @parameter
        # for di in range(len(ALL_DIRS)):
        #     d = ALL_DIRS.get[di, Dir]()

        # @parameter
        # for p in range(3):
        #     cache[State(position=i, direction=d, straight_steps=p)] = 0
        return mn

    @staticmethod
    fn part_2(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
