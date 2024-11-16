from advent_utils import AdventSolution
from algorithm import parallelize
from collections import Dict

alias HORIZONTAL = [Direction.LEFT, Direction.RIGHT]
alias POSITIVE = [Direction.RIGHT, Direction.DOWN]


@register_passable("trivial")
struct Direction:
    alias UP = Self(1)
    alias DOWN = Self(2)
    alias LEFT = Self(3)
    alias RIGHT = Self(4)
    var _value: Int

    fn __init__(out self, i: Int):
        self._value = i

    fn __eq__(self, other: Self) -> Bool:
        return self._value == other._value

    fn __ne__(self, other: Self) -> Bool:
        return not self == other


fn calculate[direction: Direction](maze: List[String]) -> Int:
    alias positive = direction in POSITIVE
    alias horizontal = direction in HORIZONTAL
    max = len(maze[0]) if horizontal else maze.size
    tot = 0
    for r in range(maze.size):
        for c in range(len(maze[r])):
            if maze[r][c] == "O":
                val = c if horizontal else r
                final_val = val + 1 if positive else max - val
                tot += final_val
    return tot


fn tilt[times: Int = 1](inout maze: List[String]):
    y_max = len(maze)
    x_max = len(maze[0])
    collection = maze

    @parameter
    for _ in range(times):

        @parameter
        fn calc_group(x: Int):
            new_str = String(capacity=y_max)
            count = 0
            ly = y_max

            for y in range(y_max - 1, -1, -1):
                if maze[y][x] == "#":
                    new_str.write("." * (ly - y - 1 - count), "O" * count, "#")
                    ly, count = y, 0

                elif maze[y][x] == "O":
                    count += 1

            new_str.write("." * (ly - count), "O" * count)
            collection[x] = new_str

        parallelize[calc_group](x_max)
        maze = collection


struct Solution(AdventSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        maze = lines
        tilt[1](maze)
        return calculate[Direction.RIGHT](maze)

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        maze = lines

        cycles, iteration = 0, 0
        mazes = Dict[String, Int](power_of_two_initial_capacity=256)

        cycles = 0
        idx = 0
        while True:
            tilt[4](maze)

            possible = mazes.get("\n".join(maze))
            if possible:
                idx = possible.value()
                iteration = len(mazes)
                cycles = iteration - idx
                break

            if cycles:
                break

            mazes["\n".join(maze)] = idx
            idx += 1

        valid_idx = (int(1e9) - iteration - 1) % cycles + (iteration - cycles)
        for i in mazes.items():
            if i[].value == valid_idx:
                maze = i[].key.splitlines()
                break

        return calculate[Direction.UP](maze)
