from advent_utils import AdventSolution, AdventResult
from utils import StaticIntTuple, StaticTuple
from collections import Dict, OptionalReg
import sys


alias Position = StaticIntTuple[2]
alias PipeList = List[Pipe]
alias Movement = StaticTuple[Position, 2]

alias Vertical = ord("|")
alias Horizontal = ord("-")
alias UpRight = ord("L")
alias UpLeft = ord("J")
alias DownRight = ord("7")
alias DownLeft = ord("F")
alias Ground = ord(".")
alias Start = ord("S")

alias VALID_PIPES = [Vertical, Horizontal, UpRight, UpLeft, DownRight, DownLeft]
alias INVALID_PIPES = [Ground, Start]
alias UP: Position = (0, 1)
alias DOWN: Position = (0, -1)
alias LEFT: Position = (-1, 0)
alias RIGHT: Position = (1, 0)


@register_passable("trivial")
struct Pipe:
    var ord: Int
    var position: Position
    var movement: Movement

    fn __init__(inout self, chr: String, position: Position):
        self.ord = ord(chr)
        self.position = position
        if self.ord == Vertical:
            self.movement = Movement(DOWN, UP)
        elif self.ord == Horizontal:
            self.movement = Movement(LEFT, RIGHT)
        elif self.ord == UpRight:
            self.movement = Movement(UP, RIGHT)
        elif self.ord == UpLeft:
            self.movement = Movement(UP, LEFT)
        elif self.ord == DownRight:
            self.movement = Movement(DOWN, RIGHT)
        elif self.ord == DownLeft:
            self.movement = Movement(DOWN, LEFT)
        elif self.ord == Ground:
            self.movement = Movement(UP, UP)
        elif self.ord == Start:
            self.movement = Movement(UP, UP)
        else:
            print("failed to parse pipe with char", chr, "and value", position)
            sys.exit(1)
            self.movement = Movement(UP, UP)  # THIS SHOULD NEVER HAPPEN


@always_inline
fn next_position(position: Position, movement: Movement) -> Position:
    return (
        position[0] + movement[0][0] + movement[1][0],
        position[1] + movement[0][1] + movement[1][1],
    )


@always_inline
fn next_pipe(map: List[List[Pipe]], current: Pipe, prev_pos: Position) -> Pipe:
    xi, yi = prev_pos[0], prev_pos[1]
    x, y = current.position[0], current.position[1]
    prev, next = current.movement[0], current.movement[1]
    if not (x - xi == prev[0] and y - yi == prev[1]):
        prev, next = next, prev
    fx, fy = x + next[0] - prev[0], y + next[1] - prev[1]
    return map[fy][fx]


fn find_connected_pipe(
    init: Pipe, map: List[List[Pipe]], ranges: (Int, Int)
) -> OptionalReg[Pipe]:
    xr, yr = ranges
    xmin, xmax = max(0, init.position[0] - 1), min(xr - 1, init.position[0] + 1)
    ymin, ymax = max(0, init.position[1] - 1), min(yr - 1, init.position[1] + 1)
    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            if map[y][x].ord in VALID_PIPES:
                ppos = map[y][x].position
                diff = Position(
                    init.position[0] - ppos[0], init.position[1] - ppos[1]
                )
                if (
                    diff == map[y][x].movement[0]
                    or diff == map[y][x].movement[1]
                ):
                    return map[y][x]
    return None


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        y_range = lines.size
        x_range = lines[0].byte_length()
        char = OptionalReg[Pipe](None)
        map = List[List[Pipe]](capacity=y_range)
        for y in range(y_range):
            map.append(List[Pipe](capacity=x_range))
            for x in range(x_range):
                c = lines[y][x]
                if ord(c) == Start:
                    char = Pipe(c, (x, y))
                map[-1].append(Pipe(c, (x, y)))

        init = char.value()
        print("finding init", init.position)
        current = find_connected_pipe(init, map, (x_range, y_range)).value()
        print("finding current", current.position)
        total = 0
        print("initialize for loop")
        while True:
            current = next_pipe(map, current, init.position)
            total += 1
            print(total, current.position)
            if current.ord == Start:
                break

        return total

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        return 0
