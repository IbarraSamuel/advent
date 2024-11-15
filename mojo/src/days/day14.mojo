from advent_utils import AdventSolution

alias HORIZONTAL = [Direction.LEFT, Direction.RIGHT]
alias POSITIVE = [Direction.RIGHT, Direction.DOWN]
alias CLOCKWISE_DIRS = [
    Direction.RIGHT,
    Direction.DOWN,
    Direction.LEFT,
    Direction.UP,
]


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

    # TO REMOVE
    fn __str__(self) -> String:
        r = (
            "UP" if self._value
            == 1 else "DOWN" if self._value
            == 2 else "LEFT" if self._value
            == 3 else "RIGHT"
        )
        return String.write("Direction(", r, ")")


fn calculate[direction: Direction](maze: List[String]) -> Int:
    # TODO: Parallelize if possible
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


fn tilt[*directions: Direction](inout maze: List[String]):
    alias directions_list = VariadicList(directions)

    @parameter
    for di in range(len(directions_list)):
        alias direction = directions_list[di]
        alias right_reprs = directions_list[
            di - 1
        ] if di > 0 else Direction.RIGHT
        tilt_single[direction, right_reprs](maze)


fn directioner[look_dir: Direction, right_repr: Direction]() -> Direction:
    @parameter
    for p in range(len(CLOCKWISE_DIRS)):
        alias curr_dir = CLOCKWISE_DIRS.get[p, Direction]()

        @parameter
        if curr_dir == look_dir:
            alias dir = p

            @parameter
            for p2 in range(len(CLOCKWISE_DIRS)):
                alias curr_d2 = CLOCKWISE_DIRS.get[p2, Direction]()

                @parameter
                if curr_d2 == right_repr:
                    alias idx = dir - p2
                    return CLOCKWISE_DIRS.get[
                        idx if idx > 0 else idx + 4, Direction
                    ]()

    return look_dir


fn tilt_single[
    direction: Direction, right_reprs: Direction
](inout maze: List[String]):
    y_max = maze.size
    x_max = maze[0].byte_length()

    alias new_dir = directioner[direction, right_reprs]()
    print(str(new_dir))
    alias dir = 1 if new_dir in [Direction.RIGHT, Direction.DOWN] else -1
    # alias arange = aranger[new_dir]

    # print(str(new_dir))

    @parameter
    if new_dir in HORIZONTAL:
        groups_len = y_max
        elems_len = x_max

    else:
        groups_len = x_max
        elems_len = y_max

    # print("groups_len:", groups_len)
    # print("elems_len:", elems_len)
    # print("acc_dir:", dir)

    collection = List[String](capacity=max(y_max, x_max))
    for g in range(groups_len):
        groups = List[(Int, Int)](capacity=groups_len)
        count = 0
        start, end = (0, elems_len) if dir == 1 else (elems_len - 1, -1)
        for e in range(start, end, dir):
            # y, x, _ = arange(elems_len, g, e)
            y, x = (g, e) if new_dir in HORIZONTAL else (e, g)
            ne = e if dir == 1 else elems_len - 1 - e
            # print("checking the element", maze[y][x])
            # print(x, y)
            if maze[y][x] == "#":
                groups.append((ne, count))
                count = 0
            if maze[y][x] == "O":
                count += 1
        groups.append((elems_len, count))

        # for group in groups:
        #     pos, rolls = group[]
        #     print("pos", pos, "and rolls", rolls)
        # print()

        new_str = String(capacity=elems_len)
        last_pos = -1
        for group in groups:
            pos, rolls = group[]
            # print("trying to use group with pos", pos, "and rolls", rolls, "and dots", (pos - 1 - last_pos - rolls))
            new_str.write("." * (pos - 1 - last_pos - rolls), "O" * rolls)
            last_pos = pos
            if pos == groups[-1][0]:
                break
            new_str.write("#")

        # print("Collected")
        collection.append(new_str)

    maze = collection

    # for v in maze:
    #     print(v[])
    # print()


struct Solution(AdventSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        # for line in lines:
        #     print(line[])
        # print()

        maze = lines
        tilt[Direction.UP](maze)
        return calculate[Direction.RIGHT](maze)

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        maze = lines
        cycles, iteration = 0, 0
        mazes = List[List[String]](capacity=256)
        # mazes.append(maze)
        cycles = 0
        while True:
            tilt[Direction.UP, Direction.LEFT, Direction.DOWN, Direction.RIGHT](
                maze
            )

            for idx in range(mazes.size):
                if mazes[idx] == maze:
                    iteration = len(mazes)
                    print(iteration)
                    cycles = iteration - idx
                    break

            if cycles:
                break

            mazes.append(maze)

        valid_idx = (int(1e9) - iteration - 1) % cycles + (iteration - cycles)
        final_maze = mazes[valid_idx]
        return calculate[Direction.UP](final_maze)
