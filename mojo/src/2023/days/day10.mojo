from utils import IndexList, StaticTuple
from collections import Dict, OptionalReg, OptionalReg
import os
from algorithm import parallelize
from testing import assert_equal, assert_true, assert_false
from advent_utils import ListSolution

alias Position = IndexList[2]
alias EMPTY_POS = Position()
alias Movement = StaticTuple[Position, 2]

alias Vertical: StaticString = "|"
alias Horizontal: StaticString = "-"
alias UpRight: StaticString = "L"
alias UpLeft: StaticString = "J"
alias DownLeft: StaticString = "7"
alias DownRight: StaticString = "F"
alias Ground: StaticString = "."
alias Start: StaticString = "S"

alias VALID_PIPES = List(
    Vertical, Horizontal, UpRight, UpLeft, DownRight, DownLeft
)
alias INVALID_PIPES = List(Ground, Start)
# alias VALID_DIAG = [Horizontal, Vertical, UpRight, DownLeft]

alias UP: Position = (0, -1)
alias DOWN: Position = (0, 1)
alias LEFT: Position = (-1, 0)
alias RIGHT: Position = (1, 0)

alias PIPE_TO_MOV = List(
    (Vertical, Movement(DOWN, UP)),
    (Horizontal, Movement(LEFT, RIGHT)),
    (UpRight, Movement(UP, RIGHT)),
    (UpLeft, Movement(UP, LEFT)),
    (DownRight, Movement(DOWN, RIGHT)),
    (DownLeft, Movement(DOWN, LEFT)),
    (Ground, Movement(UP, UP)),
    (Start, Movement(UP, UP)),
)


fn get_pipe_and_mov(char: StringSlice) -> (StaticString, Movement):
    @parameter
    for idx in range(len(PIPE_TO_MOV)):
        alias pp = PIPE_TO_MOV[idx]
        if char == pp[0]:
            return pp

    os.abort("This should never happen")
    return (StaticString("bad"), Movement())


@always_inline
fn next_position(
    previous: Position, curr_pos: Position, movement: Movement
) -> Position:
    dpos = previous - curr_pos
    mov_prev, mov_next = movement[0], movement[1]
    next = mov_next if dpos == mov_prev else mov_prev
    return curr_pos + next


fn find_connected_pipe(pos: Position, map: List[String]) -> Position:
    xr, yr = map[0].byte_length(), len(map)
    xi, yi = pos[0], pos[1]
    xmin, xmax = max(0, xi - 1), min(xr - 1, xi + 1)
    ymin, ymax = max(0, yi - 1), min(yr - 1, yi + 1)

    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            ch, mov = get_pipe_and_mov(map[y][x])
            if ch in VALID_PIPES:
                diff = pos - (x, y)
                if diff == mov[0] or diff == mov[1]:
                    return (x, y)

    os.abort("Error here. Cannot find connected pipe")
    return EMPTY_POS


struct Solution(ListSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Int32:
        prev = EMPTY_POS
        for y in range(len(lines)):
            for x in range(lines[0].byte_length()):
                c = lines[y][x]
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
    fn part_2(lines: List[String]) -> Int32:
        p1 = EMPTY_POS

        for y in range(len(lines)):
            for x in range(lines[0].byte_length()):
                if lines[y][x] == Start:
                    p1 = (x, y)
                    break
            if p1 != EMPTY_POS:
                break

        p2 = find_connected_pipe(p1, lines)

        area = 0
        n = 1

        while True:
            n += 1
            char, mov = get_pipe_and_mov(lines[p2[1]][p2[0]])
            npos = next_position(p1, p2, mov)
            p1, p2 = p2, npos
            area += p1[0] * p2[1] - p1[1] * p2[0]
            if char == Start:
                break

        return (abs(area) // 2) - (n // 2) + 1
