from advent_utils import AdventSolution


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


fn calculate[direction: Direction](maze: List[String]) -> Int:
    return 0


fn tilt[*directions: Direction](inout maze: List[String]):
    alias directions_list = VariadicList(directions)

    @parameter
    for di in range(len(directions_list)):
        alias direction = directions_list[di]
        tilt_single[direction](maze)


fn tilt_single[direction: Direction](inout maze: List[String]):
    y_max = maze.size
    x_max = maze[0].byte_length()

    # TODO: Add the iteration direction and orientation.


struct Solution(AdventSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        maze = lines
        tilt[Direction.UP](maze)
        return calculate[Direction.UP](maze)

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        maze = lines
        cycles, iteration = 0, 0
        mazes = List[List[String]](capacity=100000)
        cycles = 0
        while True:
            tilt[Direction.UP, Direction.LEFT, Direction.DOWN, Direction.RIGHT](
                maze
            )

            for idx in range(mazes.size):
                if mazes[idx] == maze:
                    iteration = mazes.size
                    cycles = iteration - idx
                    break

            if cycles:
                break

            mazes.append(maze)

        valid_idx = (int(1e9) - iteration) % cycles + (iteration - cycles)
        final_maze = mazes[valid_idx]
        return calculate[Direction.UP](final_maze)
