from collections import Dict
from algorithm.functional import parallelize
from advent_utils import AdventSolution

comptime Direction = Int
comptime UP = 1
comptime DOWN = 2
comptime LEFT = 3
comptime RIGHT = 4
comptime HORIZONTAL = [LEFT, RIGHT]
comptime POSITIVE = [RIGHT, DOWN]

comptime ord_o = ord("O")
comptime ord_ht = ord("#")
# Possible new design
# 1. Collect all rocks and rolls into a list of indices for each one.
# 2. Collect them in a way that we could check quickly from left to right, parallelizing row
# 3. Example: Rocks will be a list when each idx represents the row and each value is a list of rocks + rolls associated.
# 4. When calculating the next, we should give back a list of


fn calculate[direction: Direction](maze: String) -> Int:
    comptime positive = direction in POSITIVE
    comptime horizontal = direction in HORIZONTAL
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
            if maze.as_bytes()[r * mx + c] == ord_o:
                tot += abs(1 + (c) * mx // x_max - rev_corr)
    return tot


fn tilt[times: Int = 1](mut maze: String):
    x_max = maze.find("\n")
    y_max = len(maze) // (x_max + 1)
    var newlines = List[String](length=y_max, fill=String())

    @parameter
    for _ in range(times):

        @parameter
        fn calc_line(x: Int):
            line = String(capacity=y_max + 1)
            count = 0
            ly = y_max

            for y in reversed(range(y_max)):
                if maze.as_bytes()[y * (x_max + 1) + x] == ord_o:
                    count += 1
                elif maze.as_bytes()[y * (x_max + 1) + x] == ord_ht:
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
        maze = StringSlice("").join(newlines^)


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        maze = "\n".join(lines) + "\n"
        tilt[1](maze)
        return calculate[RIGHT](maze)

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
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
