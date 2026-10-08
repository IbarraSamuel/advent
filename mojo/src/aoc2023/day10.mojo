from std.utils import IndexList, StaticTuple
from std.collections import Dict, OptionalReg, OptionalReg
from std.testing import assert_equal, assert_true, assert_false
from std.builtin.globals import global_constant
from std.sys.intrinsics import unlikely
import std.os as os

from advent_utils import AdventSolution

comptime Position = IndexList[2]
comptime EMPTY_POS = Position()
comptime Movement = StaticTuple[Position, 2]

comptime Vertical = Byte(ord("|"))
comptime Horizontal = Byte(ord("-"))
comptime UpRight = Byte(ord("L"))
comptime UpLeft = Byte(ord("J"))
comptime DownLeft = Byte(ord("7"))
comptime DownRight = Byte(ord("F"))
comptime Ground = Byte(ord("."))
comptime Start = Byte(ord("S"))

comptime V = Codepoint(Vertical)
comptime H = Codepoint(Horizontal)
comptime UR = Codepoint(UpRight)
comptime UL = Codepoint(UpLeft)
comptime DL = Codepoint(DownLeft)
comptime DR = Codepoint(DownRight)
comptime G = Codepoint(Ground)
comptime S = Codepoint(Start)

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


def get_pipe_and_mov(char: Byte) -> Tuple[Byte, Movement]:
    comptime for pp in PIPE_TO_MOV:
        if char == pp[0]:
            return pp

    os.abort("This should never happen")


@always_inline
def next_position(
    previous: Position, curr_pos: Position, movement: Movement
) -> Position:
    var dpos = previous - curr_pos
    var mov_prev, mov_next = movement[0], movement[1]
    var next_direction = mov_next if dpos == mov_prev else mov_prev
    return curr_pos + next_direction


def find_connected_pipe[
    o: Origin
](pos: Position, map: List[StringSlice[o]]) -> Position:
    var xr, yr = map[0].byte_length(), len(map)
    var xi, yi = pos[0], pos[1]
    var xmin, xmax = max(0, xi - 1), min(xr - 1, xi + 1)
    var ymin, ymax = max(0, yi - 1), min(yr - 1, yi + 1)

    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            var ch, mov = get_pipe_and_mov(map[y].as_bytes()[x])
            if ch in materialize[VALID_PIPES]():
                var diff = pos - (x, y)
                if diff == mov[0] or diff == mov[1]:
                    return (x, y)

    os.abort("Error here. Cannot find connected pipe")


def infer_start[
    o: Origin
](x: Int, y: Int, map: List[StringSlice[o]]) -> Codepoint:
    ref line = map[y]
    var new_c = Optional[Codepoint](None)
    var found = False
    var in_x = False
    var before = False
    if x - 1 >= 0 and line.as_bytes()[x - 1] in (
        UpRight,
        DownRight,
        Horizontal,
    ):
        found = True
        in_x = True
        before = True

    if x + 1 < line.byte_length() and line.as_bytes()[x + 1] in (
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
        and map[y - 1].as_bytes()[x] in (DownLeft, DownRight, Vertical)
        and not new_c
    ):
        if found:
            new_c = UL if before else UR

    if (
        y + 1 < len(map)
        and map[y + 1].as_bytes()[x] in (UpLeft, UpRight, Vertical)
        and not new_c
    ):
        new_c = V if not in_x else DL if before else DR
    return new_c.take()


def check_line(
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

        if pipes[y].as_bytes()[x] != Byte(ord("#")):
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


def check_connect_near[
    o: Origin
](
    map: List[StringSlice[o]],
    position: Tuple[Int, Int],
    *,
    ignore: Optional[Tuple[Int, Int]] = None,
    set_pipe: Optional[Codepoint] = None,
) -> Tuple[Int, Int]:
    var x, y = position

    var pipe = Codepoint(map[y].as_bytes()[x])
    if unlikely(Bool(set_pipe)):
        pipe = set_pipe.value()

    if (
        pipe in (UL, DL, H)
        and map[y].as_bytes()[x - 1] in (UpRight, DownRight, Horizontal)
        and (unlikely(not ignore) or ignore.value() != (x - 1, y))
    ):
        return (x - 1, y)
    if (
        pipe in (UR, DR, H)
        and map[y].as_bytes()[x + 1] in (UpLeft, DownLeft, Horizontal)
        and (unlikely(not ignore) or ignore.value() != (x + 1, y))
    ):
        return (x + 1, y)
    if (
        pipe in (UL, UR, V)
        and map[y - 1].as_bytes()[x] in (DownLeft, DownRight, Vertical)
        and (unlikely(not ignore) or ignore.value() != (x, y - 1))
    ):
        return (x, y - 1)
    if (
        pipe in (DL, DR, V)
        and map[y + 1].as_bytes()[x] in (UpLeft, UpRight, Vertical)
        and (unlikely(not ignore) or ignore.value() != (x, y + 1))
    ):
        return (x, y + 1)
    if map[y - 1].as_bytes()[x] == Start:
        return (x, y - 1)
    if map[y + 1].as_bytes()[x] == Start:
        return (x, y + 1)
    if map[y].as_bytes()[x - 1] == Start:
        return (x - 1, y)
    if map[y].as_bytes()[x + 1] == Start:
        return (x + 1, y)
    os.abort("No connected pipe found")


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    def part_1(data: StringSlice) -> Int:
        var lines = data.splitlines()
        var prev = EMPTY_POS
        for y, line in enumerate(lines):
            for x, c in enumerate(line.codepoints()):
                if c == Codepoint(Start):
                    prev = (x, y)
                    break
            if prev != EMPTY_POS:
                break

        var current = find_connected_pipe(prev, lines)
        var total = 1
        while True:
            total += 1
            var ch, mov = get_pipe_and_mov(
                lines[current[1]].as_bytes()[current[0]]
            )
            var npos = next_position(
                previous=prev, curr_pos=current, movement=mov
            )
            prev, current = current, npos
            if ch == Start:
                break

        return total // 2

    @staticmethod
    def part_2(data: StringSlice) -> Int:
        var lines = data.splitlines()
        var pipes_mask = List[String](
            fill="." * lines[0].byte_length(), length=len(lines)
        )

        var idx = data.find("S")
        var start = (
            idx % (lines[0].byte_length() + 1),
            idx // (lines[0].byte_length() + 1),
        )
        pipes_mask[start[1]].unsafe_as_bytes_mut()[start[0]] = Byte(ord("#"))

        var prev = start
        var curr = check_connect_near(
            lines, prev, set_pipe=infer_start(start[0], start[1], lines)
        )
        pipes_mask[curr[1]].unsafe_as_bytes_mut()[curr[0]] = Byte(ord("#"))

        while curr != start:
            var next_pos = check_connect_near(lines, curr, ignore=prev)
            pipes_mask[next_pos[1]].unsafe_as_bytes_mut()[next_pos[0]] = Byte(
                ord("#")
            )
            prev, curr = curr, next_pos

        var tot = 0
        for y, line in enumerate(lines):
            tot += check_line(line, pipes_mask, y, lines)

        return tot
