from advent_utils import TensorSolution, FileTensor, ceil_pow_of_two
from utils import IndexList, Index
from tensor import TensorShape
from collections import Dict
from collections.set import Set
import os
import time

alias Dir = Int
alias RIGHT: Dir = 0
alias DOWN: Dir = 1
alias LEFT: Dir = 2
alias UP: Dir = 3
alias NO_DIR: Dir = 4

alias Mirr = Int
alias HORIZONTAL: Mirr = ord("-")
alias VERTICAL: Mirr = ord("|")
alias DIAG_45: Mirr = ord("/")
alias DIAG_135: Mirr = ord("\\")

alias DOT = ord(".")


# @register_passable("trivial")
# struct Mirror:
#     alias HORIZONTAL = Self(HORIZONTAL)
#     alias VERTICAL = Self(VERTICAL)
#     alias DIAG_45 = Self(DIAG_45)
#     alias DIAG_135 = Self(DIAG_135)
#     var value: UInt8

#     @implicit
#     @always_inline("nodebug")
#     fn __init__(out self, v: UInt8):
#         self.value = v

#     @always_inline("nodebug")
#     fn __eq__(self, other: Self) -> Bool:
#         return self.value == other.value

#     @always_inline("nodebug")
#     fn __ne__(self, other: Self) -> Bool:
#         return not self == other


# @register_passable("trivial")
# struct Direction:
#     alias UP = Self(UP)
#     alias DOWN = Self(DOWN)
#     alias LEFT = Self(LEFT)
#     alias RIGHT = Self(RIGHT)
#     alias NO_DIR = Self(NO_DIR)
#     var value: UInt8

#     @always_inline
#     fn __str__(self) -> String:
#         return (
#             "UP" if self
#             == Self.UP else "DOWN" if self
#             == Self.DOWN else "LEFT" if self
#             == Self.LEFT else "RIGHT"
#         )

#     @implicit
#     @always_inline("nodebug")
#     fn __init__(out self, v: UInt8):
#         self.value = v

#     @always_inline("nodebug")
#     fn __eq__(self, other: Self) -> Bool:
#         return self.value == other.value

#     @always_inline("nodebug")
#     fn __ne__(self, other: Self) -> Bool:
#         return not self == other


@always_inline("nodebug")
fn dir_repr(v: Int) -> String:
    return (
        "UP" if v
        == UP else "DOWN" if v
        == DOWN else "LEFT" if v
        == LEFT else "RIGHT"
    )


@always_inline("nodebug")
fn opposite(v: Int) -> Int:
    if v == DOWN:
        return UP
    elif v == UP:
        return DOWN
    elif v == RIGHT:
        return LEFT
    else:  # left
        return RIGHT

    @always_inline
    fn reflect_twice(self, mirror: Mirror) -> (Self, Self):
        if mirror in (Mirror.DIAG_135, Mirror.DIAG_45):
            os.abort("This cannot work with this type of mirrors.")

        if mirror.value == VERTICAL and self in (
            Direction.LEFT,
            Direction.RIGHT,
        ):
            return Self.UP, Self.DOWN
        if mirror == HORIZONTAL and self in (Direction.UP, Direction.DOWN):
            return Self.LEFT, Self.RIGHT

        os.abort("this should be unreachable. This should be reflecte once.")
        return Self.NO_DIR, Self.NO_DIR


@always_inline("nodebug")
fn delta(v: Int) -> IndexList[2]:
    if v == DOWN:
        return Index(1, 0)
    elif v == UP:
        return Index(-1, 0)
    elif v == RIGHT:
        return Index(0, 1)
    else:  # Left
        return Index(0, -1)


@always_inline
fn reflect(v: Dir, mirror: UInt8) -> (Dir, Dir):
    """Self is the position relative to the mirror.

    Returns
    -------
        The direction that an arrow would point to.
    If we should have two reflections.
    """
    if v == NO_DIR:
        return NO_DIR, NO_DIR

    if (mirror == HORIZONTAL and v in (LEFT, RIGHT)) or (
        mirror == VERTICAL and v in (UP, DOWN)
    ):
        return opposite(v), NO_DIR

    if (v == RIGHT and mirror == DIAG_45) or (v == LEFT and mirror == DIAG_135):
        return DOWN, NO_DIR

    if (v == RIGHT and mirror == DIAG_135) or (v == LEFT and mirror == DIAG_45):
        return UP, NO_DIR

    if (v == UP and mirror == DIAG_45) or (v == DOWN and mirror == DIAG_135):
        return LEFT, NO_DIR

    if (v == UP and mirror == DIAG_135) or (v == DOWN and mirror == DIAG_45):
        return RIGHT, NO_DIR

    if mirror == VERTICAL and v in (LEFT, RIGHT):
        return UP, DOWN

    if mirror == HORIZONTAL and v in (UP, DOWN):
        return LEFT, RIGHT

    os.abort("Hey, this should be unreachable.! This should be splitted")
    return NO_DIR, NO_DIR


@always_inline("nodebug")
fn oob(pos: IndexList[2], shape: TensorShape) -> Bool:
    return (
        pos[0] >= shape[0] or pos[0] < 0 or pos[1] >= shape[1] - 1 or pos[1] < 0
    )


@register_passable("trivial")
struct Cache(KeyElement):
    var idx: IndexList[2]
    var dir: Dir

    fn __init__(out self, pos: IndexList[2], dir: Dir):
        self.idx = pos
        self.dir = dir

    fn __eq__(self, other: Self) -> Bool:
        return self.idx == other.idx and self.dir == other.dir

    fn __ne__(self, other: Self) -> Bool:
        return not self == other

    fn __hash__(self) -> UInt:
        v = self.dir.value * 100000 + self.idx[0] * 1000 + self.idx[1]
        return int(v)


# fn calc_next[
#     override: Bool = False
# ](
#     pos: IndexList[2],
#     dir: Direction,
#     map: FileTensor,
#     inout cache: Dict[Cache, Int],
#     inout readed: Set[Cache],
# ) -> Int:
#     k = Cache(pos, dir)
#     shape = map.shape()
#     if pos_out_of_bounds(pos, shape):
#         cache[k] = 0
#         return 0

#     v = cache.get(k)
#     if override and v:
#         return v.value()
#     elif v:
#         return 0

#     mirr = map.load(pos)
#     print(
#         "Current mirror is:",
#         chr(int(mirr)),
#         "in position:",
#         pos,
#         "and direction",
#         str(dir),
#         "reflecting",
#         "once" if not dir.will_reflect_twice(mirr) else "twice",
#     )
#     dirs = dir.reflect_twice(mirr) if dir.will_reflect_twice(mirr) else (
#         dir.reflect_once(mirr),
#         Direction.NO_DIR,
#     )

#     tot = 0

#     @parameter
#     for i in range(2):
#         next_dir = dirs.get[i, Direction]()
#         if next_dir == Direction.NO_DIR:
#             continue
#         delta = next_dir.delta()
#         npos = pos + delta
#         while map[npos] == DOT:
#             if pos_out_of_bounds(npos, shape):
#                 npos = npos - delta
#                 break
#             npos = npos + delta
#         travel = pos - npos
#         branch_res = abs(travel[0]) + abs(travel[1])
#         if Cache(npos, next_dir.opposite()) in readed:
#             tot += branch_res
#             continue
#         readed.add(k)
#         tot += branch_res + calc_next(
#             npos, next_dir.opposite(), map, cache, readed
#         )

#     cache[k] = tot
#     return tot


# TODO: Handle Borders, and check the readed coverage
fn calc_new_pos(
    dir: Dir, pos: IndexList[2], map: FileTensor, inout readed: Set[Int]
) -> (IndexList[2], Int):
    dt = delta(dir)
    npos = pos + dt
    while int(map[npos]) not in (VERTICAL, HORIZONTAL, DIAG_45, DIAG_135):
        npos = npos + dt
        if oob(npos, map.shape()):
            npos = npos - dt
            break

        readed.add(map._compute_linear_offset(npos))
    mv = pos - npos
    return npos, abs(mv[0]) + abs(mv[1])


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned lines: FileTensor) raises -> Scalar[Self.dtype]:
        # Adjusting Tensor
        prev_y = lines.bytecount()

        i = 0
        while True:
            if lines[i] == ord("\n"):
                break
            i += 1

        map = FileTensor(
            shape=((prev_y + 1) // (i + 1), i + 1),
            ptr=lines._take_data_ptr(),
        )

        map[prev_y] = ord("\n")
        # End Tensor Adjustment

        pos = Index(0, 0)
        dir = RIGHT
        dt = delta(dir)
        tot = 1

        while int(map[pos]) not in (HORIZONTAL, VERTICAL, DIAG_135, DIAG_45):
            pos = pos + dt
            tot += 1

        readed = Set[Int]()
        queue = List[(Dir, IndexList[2])]((dir, pos))

        @parameter
        fn loff(pos: IndexList[2]) -> Int:
            return map._compute_linear_offset(pos)

        while queue:
            dir, pos = queue.pop()
            d1, d2 = reflect(opposite(dir), map[pos])
            npos, v = calc_new_pos(d1, pos, map, readed)
            queue.append((d1, npos))
            tot += v

            if d2:
                npos2, v = calc_new_pos(d2, pos, map, readed)
                queue.append((d2, npos2))
                tot += v

    #     cache = Dict[Cache, Int]()
    #     readed = Set[Cache]()
    #     pos = Index(0, 0)
    #     moving_to = Direction.RIGHT
    #     delta = moving_to.delta()
    #     init_val = 0
    #     while Mirror(map[pos]) not in (
    #         Mirror.VERTICAL,
    #         Mirror.HORIZONTAL,
    #         Mirror.DIAG_45,
    #         Mirror.DIAG_135,
    #     ):
    #         print(
    #             "Mirror",
    #             map[pos],
    #             "is not part of",
    #             "(v: {}, h: {}, d45: {}, d135: {})".format(
    #                 VERTICAL, HORIZONTAL, DIAG_45, DIAG_135
    #             ),
    #         )
    #         pos = pos + delta
    #         init_val += 1
    #         print("index is:", pos, "and val is:", chr(int(map[pos])), "\n\n")
    #         time.sleep(1)
    #     return init_val + calc_next(
    #         pos, moving_to.opposite(), map, cache, readed
    #     )

    @staticmethod
    fn part_2(owned lines: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
