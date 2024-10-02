from advent_utils import GenericAdventSolution, TestMovableResult
from utils import StaticIntTuple, StaticTuple
from collections import Dict, OptionalReg
import os
from algorithm import parallelize
from testing import assert_equal, assert_true, assert_false

alias Position = StaticIntTuple[2]
alias PipeList = List[Pipe]
alias Movement = StaticTuple[Position, 2]

alias Vertical = "|"
alias Horizontal = "-"
alias UpRight = "L"
alias UpLeft = "J"
alias DownLeft = "7"
alias DownRight = "F"
alias Ground = "."
alias Start = "S"

alias VALID_PIPES = [Vertical, Horizontal, UpRight, UpLeft, DownRight, DownLeft]
alias INVALID_PIPES = [Ground, Start]
# alias VALID_DIAG = [Horizontal, Vertical, UpRight, DownLeft]

alias UP: Position = (0, -1)
alias DOWN: Position = (0, 1)
alias LEFT: Position = (-1, 0)
alias RIGHT: Position = (1, 0)

alias PIPE_TO_MOV = [
    (Vertical, Movement(DOWN, UP)),
    (Horizontal, Movement(LEFT, RIGHT)),
    (UpRight, Movement(UP, RIGHT)),
    (UpLeft, Movement(UP, LEFT)),
    (DownRight, Movement(DOWN, RIGHT)),
    (DownLeft, Movement(DOWN, LEFT)),
    (Ground, Movement(UP, UP)),
    (Start, Movement(UP, UP)),
]


fn get_pipe_and_mov(char: String) -> (StringLiteral, Movement):
    @parameter
    for idx in range(len(PIPE_TO_MOV)):
        alias pp = PIPE_TO_MOV.get[idx, (StringLiteral, Movement)]()
        if char == pp[0]:
            return pp

    os.abort("This should never happen")
    return ("bad", Movement())


@register_passable("trivial")
struct Pipe:
    var char: StringLiteral
    var position: Position
    var movement: Movement

    fn __init__(inout self, chr: String, position: Position):
        self.char, self.movement = get_pipe_and_mov(chr)
        self.position = position


@always_inline
fn next_position(
    previous: Position, curr_pos: Position, movement: Movement
) -> Position:
    dpos = previous - curr_pos
    mov_prev, mov_next = movement[0], movement[1]
    next = mov_next if dpos == mov_prev else mov_prev
    return curr_pos + next


@always_inline
fn next_pipe(
    map: List[String], current: Pipe, prev_pos: Position
) -> (Pipe, Position):
    next_pos = next_position(
        previous=prev_pos, curr_pos=current.position, movement=current.movement
    )
    return Pipe(map[next_pos[1]][next_pos[0]], next_pos), current.position


fn convergence(a: Pipe, b: Pipe) -> Pipe:
    a1 = a.position + a.movement[0]
    a2 = a.position + a.movement[1]
    b1 = b.position + b.movement[0]
    b2 = b.position + b.movement[1]

    valid = a1 if a1 == b1 or a1 == b2 else a2

    @parameter
    for idx in range(len(VALID_PIPES)):
        ppos = VALID_PIPES.get[idx, StringLiteral]()

        p = Pipe(ppos, valid)
        if next_position(a.position, valid, p.movement) == b.position:
            return p

    os.abort("THis should not happen. Error when infering pipe on infer_pipe")
    return Pipe("a", (1, 2))


fn find_connected_pipe(
    pos: Position, map: List[String], ranges: (Int, Int)
) -> OptionalReg[Pipe]:
    xr, yr = ranges
    xi, yi = pos[0], pos[1]
    xmin, xmax = max(0, xi - 1), min(xr - 1, xi + 1)
    ymin, ymax = max(0, yi - 1), min(yr - 1, yi + 1)

    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            cpipe = Pipe(map[y][x], (x, y))
            if cpipe.char in VALID_PIPES:
                diff = pos - cpipe.position
                if diff == cpipe.movement[0] or diff == cpipe.movement[1]:
                    return cpipe

    return None


@always_inline
fn pipe_in_list(v: Pipe, l: List[Pipe, True]) -> Bool:
    for p in l:
        if v.position == p[].position:
            return True

    return False


struct Solution(GenericAdventSolution):
    alias Result: TestMovableResult = Int

    @staticmethod
    fn part_1(lines: List[String]) raises -> Self.Result:
        y_range = lines.size
        x_range = lines[0].byte_length()
        char = OptionalReg[Pipe](None)
        for y in range(y_range):
            for x in range(x_range):
                c = lines[y][x]
                if c == Start:
                    char = Pipe(c, (x, y))
                    break
            if char:
                break

        init = char.value()
        current = find_connected_pipe(
            init.position, lines, (x_range, y_range)
        ).value()
        prev_pos = init.position
        total = 1
        while True:
            current, prev_pos = next_pipe(lines, current, prev_pos)
            total += 1
            if current.char == Start:
                break

        return total // 2

    @staticmethod
    fn part_2(lines: List[String]) raises -> Self.Result:
        x_max = lines[0].byte_length()
        y_max = lines.size
        total = 0
        pipes = List[Position, True]()

        for y in range(y_max):
            for x in range(x_max):
                if lines[y][x] == Start:
                    pipes.append((x, y))
                    break
            if pipes:
                break

        current = find_connected_pipe(pipes[0], lines, (x_max, y_max)).value()
        pipes.append(current.position)

        while True:
            current, _ = next_pipe(lines, current, pipes[-2])
            if current.char == Start:
                break
            pipes.append(current.position)

        frst, lst = pipes[1], pipes[-1]
        frst_p, lst_p = Pipe(lines[frst[1]][frst[0]], frst), Pipe(
            lines[lst[1]][lst[0]], lst
        )

        repl = convergence(frst_p, lst_p)
        pipes[0] = repl.position

        # Changing logic to use

        for y in range(y_max):
            # cnt = 0
            within = False
            mid = False
            up = False
            # last = OptionalReg[StringLiteral]()
            for x in range(x_max):
                if (x, y) in pipes:
                    if lines[y][x] == Vertical:
                        within ^= True

                    elif lines[y][x] == UpRight:
                        mid, up = True, True

                    elif lines[y][x] == DownRight:
                        mid, up = True, False

                    elif lines[y][x] == DownLeft:
                        mid, within = False, up

                    elif lines[y][x] == UpLeft:
                        mid, within = False, not up
                elif within:
                    total += 1

            if within:
                print("error on line")
                print(lines[y])
                for x in range(x_max):
                    if (x, y) in pipes:
                        print(lines[y][x], end="")
                    else:
                        print("'", end="")
                print()
                within = False
                mid = False
                up = False
                # TODO: Print this but each char is one line, and print all (within, mid, up, chr)
                for x in range(x_max):
                    if (x, y) in pipes:
                        if lines[y][x] == Vertical:
                            within ^= True

                        elif lines[y][x] == UpRight:
                            mid, up = True, True

                        elif lines[y][x] == DownRight:
                            mid, up = True, False

                        elif lines[y][x] == DownLeft:
                            mid, within = False, up

                        elif lines[y][x] == UpLeft:
                            mid, within = False, not up
                    print("I" if within else lines[y][x], end="")
                print()

                os.abort("not exiting the shape of the maze for line.")
        # kjx

        #                 if c == Vertical:
        #                     within ^= True
        #                     continue
        #                 elif c == UpRight:
        #                     if last.value() == DownLeft:
        #                         within ^= True
        #                         last = None
        #                     continue
        #                 elif c == DownRight:
        #                     if last.value() == UpLeft:
        #                         within ^= True
        #                         last = None
        #                     continue
        #                 elif c == UpRight:
        #                     if not last:
        #                         last = UpRight
        #                     elif last.value() == DownLeft:
        #                         within ^= True
        #                         last = None
        #                     continue
        #                 elif c == UpRight:
        #                     if not last:
        #                         last = UpRight
        #                     elif last.value() == DownLeft:
        #                         within ^= True
        #                         last = None
        #                     continue

        # for diag in range(x_max + y_max - 1):
        #     xi = diag if diag < x_max else x_max - 1
        #     yi = 0 if diag < x_max else diag - x_max + 1
        #     xf = 0 if diag < y_max else diag - y_max + 1
        #     yf = diag if diag < y_max else y_max - 1
        #     x, y = xi, yi
        #     within = False

        #     while True:
        #         pp = Pipe(lines[y][x], (x, y))
        #         pp = pp if pp.char != Start else repl
        #         in_the_loop = pipe_in_list(pp, pipes)
        #         within ^= pp.char in VALID_DIAG and in_the_loop
        #         total += 1 if within and not in_the_loop else 0
        #         if x == xf and y == yf:
        #             break

        #         x, y = max(x - 1, xf), min(y + 1, yf)

        #     if within:
        #         os.abort("Error here. We never went out of this window+!!")

        return total
        # return 0
