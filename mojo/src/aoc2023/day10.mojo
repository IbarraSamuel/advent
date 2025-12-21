from utils import IndexList, StaticTuple
from collections import Dict, OptionalReg, OptionalReg
import os
from algorithm import parallelize
from testing import assert_equal, assert_true, assert_false
from advent_utils import AdventSolution
from builtin.globals import global_constant
from sys.intrinsics import unlikely

comptime Position = IndexList[2]
comptime EMPTY_POS = Position()
comptime Movement = StaticTuple[Position, 2]

comptime Vertical = "|"
comptime Horizontal = "-"
comptime UpRight = "L"
comptime UpLeft = "J"
comptime DownLeft = "7"
comptime DownRight = "F"
comptime Ground = "."
comptime Start = "S"
comptime V = Codepoint(ord("|"))
comptime H = Codepoint(ord("-"))
comptime UR = Codepoint(ord("L"))
comptime UL = Codepoint(ord("J"))
comptime DL = Codepoint(ord("7"))
comptime DR = Codepoint(ord("F"))
comptime G = Codepoint(ord("."))
comptime S = Codepoint(ord("S"))

comptime VALID_PIPES = (
    Vertical,
    Horizontal,
    UpRight,
    UpLeft,
    DownRight,
    DownLeft,
)
comptime INVALID_PIPES = (Ground, Start)
# comptime VALID_DIAG = [Horizontal, Vertical, UpRight, DownLeft]

comptime UP: Position = (0, -1)
comptime DOWN: Position = (0, 1)
comptime LEFT: Position = (-1, 0)
comptime RIGHT: Position = (1, 0)

comptime PIPE_TO_MOV = [
    (Vertical, Movement(DOWN, UP)),
    (Horizontal, Movement(LEFT, RIGHT)),
    (UpRight, Movement(UP, RIGHT)),
    (UpLeft, Movement(UP, LEFT)),
    (DownRight, Movement(DOWN, RIGHT)),
    (DownLeft, Movement(DOWN, LEFT)),
    (Ground, Movement(UP, UP)),
    (Start, Movement(UP, UP)),
]


fn get_pipe_and_mov(char: StringSlice) -> Tuple[String, Movement]:
    @parameter
    for pp in PIPE_TO_MOV:
        if char == pp[0]:
            return pp

    os.abort("This should never happen")


@always_inline
fn next_position(
    previous: Position, curr_pos: Position, movement: Movement
) -> Position:
    dpos = previous - curr_pos
    mov_prev, mov_next = movement[0], movement[1]
    next = mov_next if dpos == mov_prev else mov_prev
    return curr_pos + next


fn find_connected_pipe[
    o: Origin
](pos: Position, map: List[StringSlice[o]]) -> Position:
    xr, yr = len(map[0]), len(map)
    xi, yi = pos[0], pos[1]
    xmin, xmax = max(0, xi - 1), min(xr - 1, xi + 1)
    ymin, ymax = max(0, yi - 1), min(yr - 1, yi + 1)

    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            ch, mov = get_pipe_and_mov(map[y][x])
            if ch in materialize[VALID_PIPES]():
                diff = pos - (x, y)
                if diff == mov[0] or diff == mov[1]:
                    return (x, y)

    os.abort("Error here. Cannot find connected pipe")


fn infer_start[
    o: Origin
](x: Int, y: Int, map: List[StringSlice[o]]) -> Codepoint:
    ref line = map[y]
    var new_c = Optional[Codepoint](None)
    var found = False
    var in_x = False
    var before = False
    if x - 1 >= 0 and line[x - 1] in (UpRight, DownRight, Horizontal):
        found = True
        in_x = True
        before = True

    if x + 1 < len(line) and line[x + 1] in (
        UpLeft,
        DownLeft,
        Horizontal,
    ):
        if found:
            new_c = H
        else:
            found = True
            in_x = True

    if (
        y - 1 >= 0
        and map[y - 1][x] in (DownLeft, DownRight, Vertical)
        and not new_c
    ):
        if found:
            new_c = UL if before else UR

    if (
        y + 1 < len(map)
        and map[y + 1][x] in (UpLeft, UpRight, Vertical)
        and not new_c
    ):
        new_c = V if not in_x else DL if before else DR
    return new_c.take()


fn check_line(
    line: StringSlice,
    pipes: List[String],
    y: Int,
    lines: List[StringSlice[line.origin]],
) -> Int:
    var in_values = 0
    var mid_in = Optional[Codepoint](None)
    var is_in = False
    for x, cc in enumerate(line.codepoints()):
        var c = cc
        if unlikely(cc == S):
            c = infer_start(x, y, lines)

        if pipes[y][x] != StringSlice("#"):
            if is_in:
                in_values += 1
            continue

        if c == V:
            is_in ^= True
        elif c in (UR, DR):
            mid_in = c
        elif c == DL:
            if mid_in.value() == UR:
                is_in ^= True
            mid_in = None
        elif c == UL:
            if mid_in.value() == DR:
                is_in ^= True
            mid_in = None
    return in_values


fn check_connect_near[
    o: Origin
](
    map: List[StringSlice[o]],
    position: Tuple[Int, Int],
    *,
    ignore: Optional[Tuple[Int, Int]] = None,
    set_pipe: Optional[Codepoint] = None,
) -> Tuple[Int, Int]:
    x, y = position

    var pipe = Codepoint(map[y].as_bytes()[x])
    if unlikely(Bool(set_pipe)):
        pipe = set_pipe.value()

    if (
        pipe in (UL, DL, H)
        and map[y][x - 1] in (UpRight, DownRight, Horizontal)
        and (unlikely(not ignore) or ignore.value() != (x - 1, y))
    ):
        return (x - 1, y)
    if (
        pipe in (UR, DR, H)
        and map[y][x + 1] in (UpLeft, DownLeft, Horizontal)
        and (unlikely(not ignore) or ignore.value() != (x + 1, y))
    ):
        return (x + 1, y)
    if (
        pipe in (UL, UR, V)
        and map[y - 1][x] in (DownLeft, DownRight, Vertical)
        and (unlikely(not ignore) or ignore.value() != (x, y - 1))
    ):
        return (x, y - 1)
    if (
        pipe in (DL, DR, V)
        and map[y + 1][x] in (UpLeft, UpRight, Vertical)
        and (unlikely(not ignore) or ignore.value() != (x, y + 1))
    ):
        return (x, y + 1)
    if map[y - 1][x] == Start:
        return (x, y - 1)
    if map[y + 1][x] == Start:
        return (x, y + 1)
    if map[y][x - 1] == Start:
        return (x - 1, y)
    if map[y][x + 1] == Start:
        return (x + 1, y)
    os.abort("No connected pipe found")


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        prev = EMPTY_POS
        for y, line in enumerate(lines):
            for x, c in enumerate(line.codepoint_slices()):
                if c == Start:
                    prev = (x, y)
                    break
            if prev != EMPTY_POS:
                break

        next = find_connected_pipe(prev, lines)
        total = 1
        while True:
            total += 1
            ch, mov = get_pipe_and_mov(lines[next[1]][next[0]])
            npos = next_position(previous=prev, curr_pos=next, movement=mov)
            prev, next = next, npos
            if ch == Start:
                break

        return total // 2

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var pipes_mask = List[String](
            fill="." * len(lines[0]), length=len(lines)
        )

        var idx = data.find("S")
        var start = idx % (len(lines[0]) + 1), idx // (len(lines[0]) + 1)
        pipes_mask[start[1]].as_bytes_mut()[start[0]] = ord("#")

        var prev = start
        var curr = check_connect_near(
            lines, prev, set_pipe=infer_start(start[0], start[1], lines)
        )
        pipes_mask[curr[1]].as_bytes_mut()[curr[0]] = ord("#")

        while curr != start:
            next = check_connect_near(lines, curr, ignore=prev)
            pipes_mask[next[1]].as_bytes_mut()[next[0]] = ord("#")
            prev, curr = curr, next

        var tot = 0
        for y, line in enumerate(lines):
            tot += check_line(line, pipes_mask, y, lines)

        return tot
