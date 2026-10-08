from std.collections import Dict
from advent_utils import AdventSolution

comptime Direction = Int
comptime UP = 1
comptime DOWN = 2
comptime LEFT = 3
comptime RIGHT = 4
comptime HORIZONTAL = [LEFT, RIGHT]
comptime POSITIVE = [RIGHT, DOWN]

comptime ord_o = Byte(ord("O"))
comptime ord_ht = Byte(ord("#"))
# Possible new design
# 1. Collect all rocks and rolls into a list of indices for each one.
# 2. Collect them in a way that we could check quickly from left to right, parallelizing row
# 3. Example: Rocks will be a list when each idx represents the row and each value is a list of rocks + rolls associated.
# 4. When calculating the next, we should give back a list of


def calculate[direction: Direction](maze: String) -> Int:
    comptime positive = direction in POSITIVE
    comptime horizontal = direction in HORIZONTAL
    var maze_len = maze.byte_length()
    var x_max = maze.find("\n")
    var y_max = maze_len // (x_max + 1)
    var total = 0

    comptime if direction in HORIZONTAL:
        var correction = 0
        if direction == LEFT:
            correction = x_max + 1
        for r in range(y_max):
            var column_count = x_max
            if direction == LEFT:
                column_count = x_max - 1
            for step in range(column_count):
                var c = step
                if direction == LEFT:
                    c = x_max - 2 - step
                if maze.as_bytes()[r * (x_max + 1) + c] == ord_o:
                    total += abs(1 + c * (x_max + 1) // x_max - correction)
    else:
        var correction = 0
        if direction == UP:
            correction = y_max + 1
        for r in range(x_max):
            for step in range(y_max):
                var c = step * (x_max + 1)
                if direction == UP:
                    c = (y_max - step - 1) * (x_max + 1)
                if maze.as_bytes()[r + c] == ord_o:
                    total += abs(1 + c // x_max - correction)
    return total


def tilt[times: Int = 1](mut maze: String):
    var x_max = maze.find("\n")
    var y_max = maze.byte_length() // (x_max + 1)
    var newlines = List[String]()
    for _ in range(y_max):
        newlines.append(String())

    comptime for _ in range(times):

        for x in range(x_max):
            var line = String()
            var count = 0
            var ly = y_max
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
        maze = StringSlice("").join(newlines^)


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    def part_1(data: StringSlice) -> Int:
        var lines = data.splitlines()
        var maze = "\n".join(lines) + "\n"
        tilt[1](maze)
        return calculate[RIGHT](maze)

    @staticmethod
    def part_2(data: StringSlice) -> Int:
        var lines = data.splitlines()
        var maze = "\n".join(lines) + "\n"
        var mazes = Dict[String, Int](capacity=256)

        var idx = 0
        var iteration: Int
        var cycles: Int
        while True:
            tilt[4](maze)
            var possible = mazes.get(maze)
            if possible:
                idx = possible.value()
                iteration = len(mazes)
                cycles = iteration - idx
                break

            mazes[maze] = idx
            idx += 1

        var valid_idx = (
            1_000_000_000 - iteration - 1
        ) % cycles + (iteration - cycles)
        for it in mazes.items():
            if it.value == valid_idx:
                maze = it.key
                break

        return calculate[UP](maze)
