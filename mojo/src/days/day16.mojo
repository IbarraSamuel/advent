from advent_utils import TensorSolution, FileTensor, ceil_pow_of_two
from utils import IndexList, Index
from tensor import TensorShape
from collections import Dict
from collections.set import Set
import os
import time

alias Dir = Int
alias RIGHT: Dir = 4
alias DOWN: Dir = 1
alias LEFT: Dir = 2
alias UP: Dir = 3
alias NO_DIR: Dir = 0

alias Mirr = Int
alias HORIZONTAL: Mirr = ord("-")
alias VERTICAL: Mirr = ord("|")
alias DIAG_45: Mirr = ord("/")
alias DIAG_135: Mirr = ord("\\")
alias MIRRORS = (HORIZONTAL, VERTICAL, DIAG_135, DIAG_45)

alias DOT = ord(".")


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
    if int(mirror) not in MIRRORS:
        print("!!ALERT!! WHY THIS IS HAPPENING?")
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
        v = self.dir.value * 1000000 + self.idx[0] * 1000 + self.idx[1]
        return int(v)


fn calc_new_pos(
    dir: Dir, pos: IndexList[2], map: FileTensor, inout readed: Set[Int]
) -> (IndexList[2], Int):
    dt = delta(dir)
    npos = pos
    while int(map[npos]) == DOT or npos == pos:
        npos = npos + dt
        if oob(npos, map.shape()) or map._compute_linear_offset(npos) in readed:
            npos = npos - dt
            break
        print(npos)
        readed.add(map._compute_linear_offset(npos))
    print("Stopped!!")
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
        # End of Tensor Adjust

        print(map)

        pos = Index(0, 0)
        dir = RIGHT

        readed = Set[Int](0)  # This may be better if it's a list
        # TODO: Do not check collisions maybe
        pos, _ = calc_new_pos(dir, pos, map, readed)
        queue = List[(Dir, IndexList[2])]((dir, pos))

        while queue:
            dir, pos = queue.pop()
            print(
                "Starting on",
                pos,
                "with dir",
                dir_repr(dir),
                "and current:",
                str(int(map[pos])),
            )
            d1, d2 = reflect(opposite(dir), map[pos])
            if d1:
                npos, _ = calc_new_pos(d1, pos, map, readed)
                if npos != pos and int(map[npos]) in MIRRORS:
                    queue.append((d1, npos))

            if d2:
                npos2, _ = calc_new_pos(d2, pos, map, readed)
                if npos2 != pos and int(map[npos2]) in MIRRORS:
                    queue.append((d2, npos2))

        for y in range(map.shape()[0]):
            for x in range(map.shape()[1] - 1):
                idx = Index(y, x)
                print(chr(int(map[idx])), end="")
            print("", y)
        for i in range(map.shape()[1] - 1):
            print(i, end="")
        print()

        for y in range(map.shape()[0]):
            for x in range(map.shape()[1] - 1):
                idx = Index(y, x)
                if map._compute_linear_offset(idx) in readed:
                    print("#", end="")
                    continue

                print(chr(int(map[idx])), end="")
            print("", y)
        print()

        return len(readed)

    @staticmethod
    fn part_2(owned lines: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
