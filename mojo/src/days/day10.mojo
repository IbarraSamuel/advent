from advent_utils import AdventSolution, AdventResult
from utils import StaticIntTuple, StaticTuple
from collections import Dict, OptionalReg
import sys
from algorithm import parallelize
from testing import assert_equal, assert_true, assert_false

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
alias VALID_DIAG = [Horizontal, Vertical, UpRight, DownLeft]

alias UP: Position = (0, -1)
alias DOWN: Position = (0, 1)
alias LEFT: Position = (-1, 0)
alias RIGHT: Position = (1, 0)


@register_passable("trivial")
# struct Pipe(Representable):
struct UnpinnedPipe:
    var movement: Movement

    fn __init__(inout self, ord: Int):
        if ord == Vertical:
            self.movement = Movement(DOWN, UP)
        elif ord == Horizontal:
            self.movement = Movement(LEFT, RIGHT)
        elif ord == UpRight:
            self.movement = Movement(UP, RIGHT)
        elif ord == UpLeft:
            self.movement = Movement(UP, LEFT)
        elif ord == DownRight:
            self.movement = Movement(DOWN, RIGHT)
        elif ord == DownLeft:
            self.movement = Movement(DOWN, LEFT)
        elif ord == Ground:
            self.movement = Movement(UP, UP)
        elif ord == Start:
            self.movement = Movement(UP, UP)
        else:
            print("failed to parse pipe with ord", ord)
            sys.exit(1)
            self.movement = Movement(UP, UP)  # THIS SHOULD NEVER HAPPEN


@register_passable("trivial")
# struct Pipe(Representable):
struct Pipe:
    var ord: Int
    var position: Position
    var movement: Movement

    fn __init__(inout self, chr: String, position: Position):
        self.ord = ord(chr)
        unpp = UnpinnedPipe(self.ord)
        self.position = position
        self.movement = unpp.movement

    fn __repr__(self) -> String:
        return (
            "Pipe(char: "
            + chr(self.ord)
            + ", position: "
            + str(self.position)
            + ")"
        )

    fn __eq__(self, other: Self) -> Bool:
        return self.position == other.position

    fn __neq__(self, other: Self) -> Bool:
        return not self == other


@always_inline
fn next_position(previous: Position, pipe: Pipe) -> Position:
    curr_pos, movement = pipe.position, pipe.movement
    dpos = previous - curr_pos
    mov_prev, mov_next = movement[0], movement[1]
    next = mov_next if dpos == mov_prev else mov_prev
    return curr_pos + next


@always_inline
fn next_pipe(
    map: List[String], current: Pipe, prev_pos: Position
) -> (Pipe, Position):
    next_pos = next_position(previous=prev_pos, pipe=current)
    return Pipe(map[next_pos[1]][next_pos[0]], next_pos), current.position


fn convergence(a: Pipe, b: Pipe) -> Pipe:
    # print(a.__repr__(), b.__repr__())
    a1 = a.position + a.movement[0]
    a2 = a.position + a.movement[1]
    b1 = b.position + b.movement[0]
    b2 = b.position + b.movement[1]

    valid = a1 if a1 == b1 or a1 == b2 else a2

    # d1 = a.position - valid
    # d2 = b.position - valid

    # print("inferring pipe on", valid, "with diffs:", d1, d2)

    @parameter
    for idx in range(len(VALID_PIPES)):
        ppos = VALID_PIPES.get[idx, Int]()
        p = Pipe(chr(ppos), valid)
        if next_position(a.position, p) == b.position:
            return p

    print("THis should not happen. Error when infering pipe on infer_pipe")
    sys.exit(1)
    return Pipe("a", (1, 2))


fn find_connected_pipe(
    init: Pipe, map: List[String], ranges: (Int, Int)
) -> OptionalReg[Pipe]:
    xr, yr = ranges
    xi, yi = init.position[0], init.position[1]
    xmin, xmax = max(0, xi - 1), min(xr - 1, xi + 1)
    ymin, ymax = max(0, yi - 1), min(yr - 1, yi + 1)

    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            cpipe = Pipe(map[y][x], (x, y))
            if cpipe.ord in VALID_PIPES:
                diff = init.position - cpipe.position
                if diff == cpipe.movement[0] or diff == cpipe.movement[1]:
                    return cpipe

    return None


@always_inline
fn pipe_in_list(v: Pipe, l: List[Pipe, True]) -> Bool:
    for p in l:
        if v == p[]:
            return True

    return False


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
        current = find_connected_pipe(init, lines, (x_range, y_range)).value()
        prev_pos = init.position
        total = 1
        while True:
            current, prev_pos = next_pipe(lines, current, prev_pos)
            total += 1
            if current.ord == Start:
                break

        return total // 2

    # Actually, here you need to put
    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        # print("Hi")
        # test_convergence()
        x_max = lines[0].byte_length()
        y_max = lines.size
        total = 0
        pipes = List[Pipe, True]()

        for y in range(y_max):
            for x in range(x_max):
                c = lines[y][x]
                if ord(lines[y][x]) == Start:
                    pipes.append(Pipe(c, (x, y)))
                    break
            if pipes:
                break

        current = find_connected_pipe(pipes[0], lines, (x_max, y_max)).value()
        pipes.append(current)
        while True:
            current, _ = next_pipe(lines, pipes[-1], pipes[-2].position)
            if current.ord == Start:
                break
            pipes.append(current)
        repl = convergence(pipes[1], pipes[-1])
        pipes[0] = repl

        for diag in range(x_max + y_max - 1):
            xi = diag if diag < x_max else x_max - 1
            yi = 0 if diag < x_max else diag - x_max + 1
            xf = 0 if diag < y_max else diag - y_max + 1
            yf = diag if diag < y_max else y_max - 1
            # print("from (", xi, yi, ") to (", xf, yf, ")")
            x, y = xi, yi
            within = False

            while True:
                pp = Pipe(lines[y][x], (x, y))
                pp = pp if pp.ord != Start else repl
                in_the_loop = pipe_in_list(pp, pipes)
                within ^= pp.ord in VALID_DIAG and in_the_loop
                total += 1 if within and not in_the_loop else 0
                # print(
                #     lines[y][x], "on position (", x, y, ")", ". mode:", within
                # )
                if x == xf and y == yf:
                    break

                x, y = max(x - 1, xf), min(y + 1, yf)

            if within:
                print("Error here. We never went out of this window+!!")
                sys.exit()

        return total


fn test_convergence():
    p1 = Pipe("|", (0, 0))
    p2 = Pipe("-", (1, 1))
    exp = Pipe("L", (0, 1))
    print("expected:", end="")
    print(exp.__repr__())
    print("Found:", end="")
    p3 = convergence(p1, p2)
    print(p3.__repr__())
    print(p3.position == exp.position)
    print(p3.ord == exp.ord)
