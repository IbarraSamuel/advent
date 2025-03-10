from advent_utils import TensorSolution, FileTensor
from utils import IndexList, Index
from tensor import TensorShape
from collections import Dict
from collections.set import Set
from algorithm import parallelize
import os

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
alias LN = ord("\n")


# # @always_inline("nodebug")
# fn dir_repr(v: Int) -> String:
#     return (
#         "UP" if v
#         == UP else "DOWN" if v
#         == DOWN else "LEFT" if v
#         == LEFT else "RIGHT"
#     )


# @always_inline("nodebug")
fn opposite(v: Dir) -> Int:
    if v == DOWN:
        return UP
    elif v == UP:
        return DOWN
    elif v == RIGHT:
        return LEFT
    else:  # left
        return RIGHT


# @always_inline("nodebug")
fn delta(v: Int) -> IndexList[2]:
    if v == DOWN:
        return Index(1, 0)
    elif v == UP:
        return Index(-1, 0)
    elif v == RIGHT:
        return Index(0, 1)
    else:  # Left
        return Index(0, -1)


# @always_inline
fn reflect(v: Dir, mirror: UInt8) -> (Dir, Dir):
    """Self is the position relative to the mirror.

    Returns
    -------
        The direction that an arrow would point to.
    If we should have two reflections.
    """
    if Int(mirror) not in MIRRORS:
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


# @always_inline("nodebug")
fn oob(pos: IndexList[2], shape: (Int, Int)) -> Bool:
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
        return Int(v)


fn calc_new_pos(
    dir: Dir,
    pos: IndexList[2],
    map: FileTensor,
    sp: (Int, Int),
    mut readed: Set[Int],
    mut cache: Set[Cache],
    # mut s: String,
) -> (IndexList[2], Int):
    dt = delta(dir)
    npos = pos
    while map[npos] == DOT or npos == pos:
        npos = npos + dt
        k = Cache(npos, dir)
        if oob(npos, sp) or map[npos] == LN or k in cache:
            npos = npos - dt
            break
        readed.add(map._compute_linear_offset(npos))
        cache.add(k)
    mv = pos - npos
    return npos, abs(mv[0]) + abs(mv[1])


fn calc_energized(
    map: FileTensor, sp: (Int, Int), owned pos: IndexList[2], owned dir: Dir
) -> Int:
    readed = Set[Int](map._compute_linear_offset(pos))
    cache = Set[Cache](Cache(pos, dir))

    if Int(map[pos]) not in MIRRORS:
        pos, _ = calc_new_pos(dir, pos, map, sp, readed, cache)

    queue = List[(Dir, IndexList[2])]((dir, pos))

    while queue:
        dir, pos = queue.pop()
        d1, d2 = reflect(opposite(dir), map[pos])
        if d1:
            npos, _ = calc_new_pos(d1, pos, map, sp, readed, cache)
            if npos != pos and Int(map[npos]) in MIRRORS:
                queue.append((d1, npos))

        if d2:
            npos2, _ = calc_new_pos(d2, pos, map, sp, readed, cache)
            if npos2 != pos and Int(map[npos2]) in MIRRORS:
                queue.append((d2, npos2))

    # @parameter
    # if log:
    #     try:
    #         w = open("../mojo.txt", "w")
    #         for i in range(map.num_elements()):
    #             if i in readed:
    #                 w.write("#")
    #                 continue
    #             w.write(chr(int(map[i])))
    #         w.close()
    #     except:
    #         pass

    return len(readed)


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned map: FileTensor) raises -> Scalar[Self.dtype]:
        # 46 .. 7199
        pos = Index(0, 0)
        dir = RIGHT
        sp = map.shape()

        return calc_energized(
            map,
            (sp[0], sp[1]),
            pos,
            dir,
        )

    @staticmethod
    fn part_2(owned map: FileTensor) raises -> Scalar[Self.dtype]:
        # 51 .. 7438
        sp = map.shape()
        ym, xm = sp[0], sp[1] - 1
        indexes = List[(IndexList[2], Dir)](capacity=(ym + xm) * 2)

        for y in range(ym):
            indexes.append((Index(y, 0), RIGHT))
            indexes.append((Index(y, xm - 1), LEFT))
        for x in range(xm):
            indexes.append((Index(0, x), DOWN))
            indexes.append((Index(ym - 1, x), UP))

        # # test
        # tst = List[String]()
        # for _ in indexes:
        #     tst.append("")
        # # test

        results = SIMD[DType.int32, 512](0)

        @parameter
        fn calc_length(idx: Int):
            pos, dir = indexes[idx]
            results[idx] = calc_energized(map, (ym, xm + 1), pos, dir)
            # tst[idx] = w

        parallelize[calc_length](len(indexes))

        # test
        # mx = 0
        # idxm = 0
        # for x in range(map.num_elements()):
        #     print(chr(int(map[x])), end="")

        # for v in range(results.size):
        #     if results[idxm] < results[v]:
        #         idxm, mx = v, int(results[v])

        # print(
        #     "max count is: ",
        #     mx,
        #     " in position: ",
        #     indexes[idxm][0],
        #     " and direction: ",
        #     dir_repr(indexes[idxm][1]),
        #     " with map:\n",
        #     tst[idxm],
        #     sep="\n",
        # )
        # test

        return results.reduce_max()
