from advent_utils import AdventSolution, AdventResult
from utils import StaticIntTuple, StaticTuple
from collections import Dict, OptionalReg
import sys
from time import sleep

alias Position = StaticIntTuple[2]
alias PipeList = List[Pipe]
alias Movement = StaticTuple[Position, 2]

alias Vertical = ord("|")
alias Horizontal = ord("-")
alias UpRight = ord("L")
alias UpLeft = ord("J")
alias DownLeft = ord("7")
alias DownRight = ord("F")
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
fn next_position(previous: Position, pipe: Pipe) -> Position:
    curr_pos, movement = pipe.position, pipe.movement
    mov_prev, mov_next = movement[0], movement[1]
    if curr_pos == previous + mov_prev:
        return previous + mov_prev + mov_next
    if curr_pos == previous + mov_next:
        return previous - mov_prev - mov_next
    print("This should not occur.")
    sys.exit(1)
    return curr_pos


@always_inline
fn next_pipe(
    map: List[List[Pipe]], current: Pipe, prev_pos: Position
) -> (Pipe, Position):
    next_pos = next_position(previous=prev_pos, pipe=current)
    return map[next_pos[1]][next_pos[0]], current.position


fn find_connected_pipe(
    init: Pipe, map: List[List[Pipe]], ranges: (Int, Int)
) -> OptionalReg[Pipe]:
    xr, yr = ranges
    xmin, xmax = max(0, init.position[0] - 1), min(xr - 1, init.position[0] + 1)
    ymin, ymax = max(0, init.position[1] - 1), min(yr - 1, init.position[1] + 1)

    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            cpipe = map[y][x]
            if cpipe.ord in VALID_PIPES:
                diff = cpipe.position - init.position
                if diff == cpipe.movement[0] or diff == cpipe.movement[1]:
                    return cpipe
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
        current = find_connected_pipe(init, map, (x_range, y_range)).value()
        prev_pos = init.position
        total = 0
        print(
            total,
            ":",
            chr(init.ord),
            prev_pos,
            "->",
            chr(current.ord),
            current.position,
        )
        while True:
            current, prev_pos = next_pipe(map, current, prev_pos)
            total += 1
            print(
                total,
                ":",
                lines[prev_pos[1]][prev_pos[0]],
                prev_pos,
                "->",
                chr(current.ord),
                current.position,
            )
            sleep(0.5)
            if current.ord == Start:
                break

        return total

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        return 0
