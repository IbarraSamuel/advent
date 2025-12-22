from advent_utils import AdventSolution
from utils import IndexList, Index
from hashlib.hasher import Hasher
from collections.set import Set
from algorithm import parallelize
import os
from time import sleep

comptime Pos = IndexList[2]

comptime Dir = Int
comptime RIGHT: Dir = 3
comptime DOWN: Dir = 0
comptime LEFT: Dir = 1
comptime UP: Dir = 2
comptime NO_DIR: Dir = -1

comptime Mirr = Int
comptime HORIZONTAL: Mirr = ord("-")
comptime VERTICAL: Mirr = ord("|")
comptime DIAG_45: Mirr = ord("/")
comptime DIAG_135: Mirr = ord("\\")
comptime MIRRORS = (HORIZONTAL, VERTICAL, DIAG_135, DIAG_45)

comptime DOT = ord(".")


@always_inline("nodebug")
fn opposite(v: Dir) -> Dir:
    if v == DOWN:
        return UP
    elif v == UP:
        return DOWN
    elif v == RIGHT:
        return LEFT
    elif v == LEFT:  # left
        return RIGHT

    os.abort("No correct direction provided to mirrors.")


@always_inline("nodebug")
fn delta(d: Dir) -> IndexList[2]:
    if d == DOWN:
        return Index(0, 1)
    elif d == UP:
        return Index(0, -1)
    elif d == RIGHT:
        return Index(1, 0)
    elif d == LEFT:  # Left
        return Index(-1, 0)

    os.abort("No correct direction provided to delta")


# # @always_inline
fn reflect(dir: Dir, mirror: Mirr) -> Tuple[Dir, Dir]:
    """Self is the position relative to the mirror.

    Returns
    -------
        The direction that an arrow would point to.
    If we should have two reflections.
    """
    if mirror not in MIRRORS:
        os.abort("You are trying to reflect in something that is not a mirror.")
        # return NO_DIR, NO_DIR

    if (mirror == HORIZONTAL and dir in (LEFT, RIGHT)) or (
        mirror == VERTICAL and dir in (UP, DOWN)
    ):
        return dir, NO_DIR

    if (dir == RIGHT and mirror == DIAG_45) or (
        dir == LEFT and mirror == DIAG_135
    ):
        return UP, NO_DIR

    if (dir == RIGHT and mirror == DIAG_135) or (
        dir == LEFT and mirror == DIAG_45
    ):
        return DOWN, NO_DIR

    if (dir == UP and mirror == DIAG_45) or (
        dir == DOWN and mirror == DIAG_135
    ):
        return RIGHT, NO_DIR

    if (dir == UP and mirror == DIAG_135) or (
        dir == DOWN and mirror == DIAG_45
    ):
        return LEFT, NO_DIR

    if mirror == VERTICAL and dir in (LEFT, RIGHT):
        return UP, DOWN

    if mirror == HORIZONTAL and dir in (UP, DOWN):
        return LEFT, RIGHT

    os.abort("Hey, this should be unreachable.! This should be splitted")


@always_inline("nodebug")
fn out_of_bounds(pos: Pos, shape: Tuple[Int, Int]) -> Bool:
    return (
        pos[0] > shape[0] - 1
        or pos[0] < 0
        or pos[1] > shape[1] - 1
        or pos[1] < 0
    )


@always_inline("nodebug")
fn index[o: Origin](pos: Pos, map: List[StringSlice[o]]) -> String:
    return map[pos[1]][pos[0]]


fn next_mirror[
    o: Origin, oo: MutOrigin
](
    dir: Dir, pos: Pos, map: List[StringSlice[o]], used_map: Span[Byte, oo]
) -> Tuple[Int, Bool, Pos]:
    """Need to validate if it stopped because you are in oob or it's a mirror.
    """
    var bounds = len(map[0]), len(map)
    var steps = 0
    var npos = pos + delta(dir)

    while not out_of_bounds(npos, bounds):
        var i = pos_to_int(npos, (bounds[0] + 1, bounds[1]))
        if used_map[i] != ord("#"):
            used_map[i] = ord("#")
            steps += 1
        if ord(index(npos, map)) != DOT:
            break
        npos = npos + delta(dir)

    var is_mirr = not out_of_bounds(npos, bounds)
    return steps, is_mirr, npos


fn reflect_and_find[
    o: Origin, oo: MutOrigin
](
    coming_from: Dir,
    pos: Pos,
    map: List[StringSlice[o]],
    used_map: Span[Byte, oo],
) -> Tuple[Int, Optional[Tuple[Dir, Pos]], Optional[Tuple[Dir, Pos]]]:
    # var bounds = len(map[0]), len(map)
    var mirror = ord(index(pos, map))
    var dir1, dir2 = reflect(coming_from, mirror)

    var steps = 0
    var npos1 = Optional[Tuple[Dir, Pos]]()
    var npos2 = Optional[Tuple[Dir, Pos]]()

    if dir1 != NO_DIR:
        var n_steps, is_mirr, new_mirr = next_mirror(dir1, pos, map, used_map)
        steps += n_steps
        if is_mirr:
            npos1 = dir1, new_mirr

    if dir2 != NO_DIR:
        var n_steps, is_mirr, new_mirr = next_mirror(dir2, pos, map, used_map)
        steps += n_steps
        if is_mirr:
            npos2 = dir2, new_mirr
    return steps, npos1, npos2


@always_inline("nodebug")
fn pos_to_int(pos: Pos, bounds: Tuple[Int, Int]) -> Int:
    return pos[1] * bounds[0] + pos[0]


@always_inline("nodebug")
fn is_readed_or_set_readed[
    o: MutOrigin, set_mirror: Mirr = -1
](
    bytes_map: Span[Byte, o],
    dir: Dir,
    pos: Pos,
    bounds: Tuple[Int, Int],
    *,
    mirror: Mirr = -1,
) -> Bool:
    var checker = ord("R")
    var idx = pos_to_int(pos, bounds)
    var bounds_size = bounds[0] * bounds[1]
    ref m = bytes_map[bounds_size * dir + idx]

    if m == checker:
        return True

    m = checker
    if mirror != -1:
        var d1, d2 = reflect(dir, mirror)
        if d2 == NO_DIR and mirror not in (VERTICAL, HORIZONTAL):
            # d1 is the out direction from dir. So doing opposite(d1) will catch what we already used
            bytes_map[bounds_size * opposite(d1) + idx] = checker
        # Then only flats accessed from side can be here
        elif d2 != NO_DIR:
            bytes_map[bounds_size * opposite(dir) + idx] = checker
            # just save the opposite going to
    return False


fn dir_to_str(dir: Dir) -> StaticString:
    if dir == UP:
        return "UP"
    if dir == DOWN:
        return "DOWN"
    if dir == LEFT:
        return "LEFT"
    if dir == RIGHT:
        return "RIGHT"
    if dir == NO_DIR:
        return "NO DIR!"
    os.abort("is not a dir!")


fn calc_energized[
    o: Origin,
    oo: MutOrigin,
    ooo: MutOrigin,
](
    map: List[StringSlice[o]],
    read_map: Span[Byte, oo],
    bounds: Tuple[Int, Int],
    p: Pos,
    dir: Dir,
    map_used: Span[Byte, ooo],
) -> Int:
    # Storing readed indexes as a int
    # set_readed(read_map, pos_to_int(pos, bounds))
    var steps = 1
    map_used[pos_to_int(p, (bounds[0] + 1, bounds[1]))] = ord("#")
    var queue = List[Tuple[Dir, Pos]](capacity=100)
    var pos = p

    if ord(index(pos, map)) not in MIRRORS:
        nsteps, is_mirror, pos = next_mirror(dir, pos, map, map_used)
        steps += nsteps
        if not is_mirror:
            return steps

    queue.append((dir, pos))

    while queue:
        var (dir, pos) = queue.pop()

        if is_readed_or_set_readed(
            read_map, dir, pos, bounds, mirror=ord(index(pos, map))
        ):
            continue

        var n_steps, n1, n2 = reflect_and_find(dir, pos, map, map_used)
        steps += n_steps

        if n1 == None and n2 == None:
            continue

        if n1:
            queue.append(n1.take())
        if n2:
            queue.append(n2.take())

    # @parameter
    # fn reflect_and_f[
    #     o: Origin
    # ](dir: Dir, pos: Pos, map: List[StringSlice[o]]) -> Int:
    #     if is_readed_or_set_readed(read_map, dir, pos, bounds):
    #         # Reduce current mirror from count because it's already part of the count
    #         return -1

    #     var steps, n1, n2 = reflect_and_find(dir, pos, map)

    #     if n1 == None and n2 == None:
    #         return steps

    #     var results = SIMD[DType.uint32, 2](0, 0)

    #     @parameter
    #     fn r1(i: Int):
    #         var steps = 0
    #         var n = n1 if i == 0 else n2
    #         if n:
    #             d, p = n.unsafe_value()
    #             steps = reflect_and_f(d, p, map)
    #         results[i] = steps

    #     parallelize[r1](2)

    #     return Int(results.reduce_add())

    # return steps + reflect_and_f(dir, pos, map)

    return steps


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        # Mask for each mirror, but shifted by the direction received
        var read_map = " " * len(data) * 4
        var used_map = String(data)
        var map = data.splitlines()

        var pos = Index(0, 0)
        var dir = RIGHT
        var bounds = len(map[0]), len(map)

        return calc_energized(
            map,
            read_map.as_bytes_mut(),
            bounds,
            pos,
            dir,
            used_map.as_bytes_mut(),
        )

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        # 51 .. 7438
        var map = data.splitlines()
        var bounds = len(map[0]), len(map)
        var possibilities = 2 * (len(map[0]) + len(map))
        var indexes = List[Tuple[Pos, Dir]](capacity=possibilities)

        for y in range(bounds[1]):
            indexes.append((Index(0, y), RIGHT))
            indexes.append((Index(bounds[0] - 1, y), LEFT))

        for x in range(bounds[0]):
            indexes.append((Index(x, 0), DOWN))
            indexes.append((Index(x, bounds[1] - 1), UP))

        results = SIMD[DType.int32, 512](0)

        @parameter
        fn calc_length(idx: Int):
            var pos, dir = indexes[idx]
            var read_map = " " * len(data) * 4
            var used_map = String(data)

            results[idx] = calc_energized(
                map,
                read_map.as_bytes_mut(),
                bounds,
                pos,
                dir,
                used_map.as_bytes_mut(),
            )

        parallelize[calc_length](len(indexes))

        return results.reduce_max()
