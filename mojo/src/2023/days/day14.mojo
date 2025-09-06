from collections import Dict
from algorithm.functional import parallelize
from advent_utils import ListSolution

alias Direction = Int
alias UP = 1
alias DOWN = 2
alias LEFT = 3
alias RIGHT = 4
alias HORIZONTAL = [LEFT, RIGHT]
alias POSITIVE = [RIGHT, DOWN]


# Possible new design
# 1. Collect all rocks and rolls into a list of indices for each one.
# 2. Collect them in a way that we could check quickly from left to right, parallelizing row
# 3. Example: Rocks will be a list when each idx represents the row and each value is a list of rocks + rolls associated.
# 4. When calculating the next, we should give back a list of


fn calculate[direction: Direction](maze: String) -> Int:
    alias positive = direction in POSITIVE
    alias horizontal = direction in HORIZONTAL
    len = len(maze)
    x_max = maze.find("\n")
    y_max = len // (x_max + 1)

    @parameter
    if direction == RIGHT:
        mx = x_max + 1
        c_iter = range(0, x_max, 1)
        r_iter = range(y_max)  # dk
        rev_corr = 0
    elif direction == LEFT:
        mx = x_max + 1
        c_iter = reversed(range(x_max - 1))
        r_iter = range(y_max)  # dk
        rev_corr = x_max + 1
    elif direction == DOWN:
        mx = 1
        c_iter = range(0, len, x_max + 1)  # dk
        r_iter = range(x_max)
        rev_corr = 0
    else:  # UP
        mx = 1
        c_iter = reversed(range(0, len, x_max + 1))
        r_iter = range(x_max)  # dk
        rev_corr = y_max + 1

    tot = 0
    for r in r_iter:
        for c in c_iter:
            if maze[r * mx + c] == "O":
                tot += abs(1 + (c) * mx // x_max - rev_corr)
    return tot


fn tilt[times: Int = 1](mut maze: String):
    x_max = maze.find("\n")
    y_max = len(maze) // (x_max + 1)
    lines = maze.splitlines()
    newlines = List[String](capacity=len(lines))

    @parameter
    for _ in range(times):

        @parameter
        fn calc_line(x: Int):
            line = String(capacity=y_max + 1)
            count = 0
            ly = y_max

            for y in reversed(range(y_max)):
                if maze[y * (x_max + 1) + x] == "O":
                    count += 1
                elif maze[y * (x_max + 1) + x] == "#":
                    line.write(
                        "." * (ly - y - 1 - count),
                        "O" * count,
                        "#",
                    )
                    ly = y
                    count = 0
            line.write(
                "." * (ly - count),
                "O" * count,
                "\n",
            )
            newlines[x] = line^

        parallelize[calc_line](x_max)
        maze = StringSlice("").join(lines^)


struct Solution(ListSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1[o: Origin](lines: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        maze = "\n".join(lines) + "\n"
        tilt[1](maze)
        return calculate[RIGHT](maze)

    @staticmethod
    fn part_2[o: Origin](lines: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        maze = "\n".join(lines) + "\n"
        mazes = Dict[String, Int](power_of_two_initial_capacity=256)

        idx = 0
        while True:
            tilt[4](maze)
            possible = mazes.get(maze)
            if possible:
                idx = possible.value()
                iteration = len(mazes)
                cycles = iteration - idx
                break

            mazes[maze] = idx
            idx += 1

        valid_idx = (Int(1e9) - iteration - 1) % cycles + (iteration - cycles)
        for it in mazes.items():
            if it.value == valid_idx:
                maze = it.key
                break

        return calculate[UP](maze)
