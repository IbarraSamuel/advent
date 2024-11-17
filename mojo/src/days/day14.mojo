from advent_utils import AdventSolution
from algorithm import parallelize
from collections import Dict, InlineList, InlineArray
from utils import StaticTuple

alias ROLL = "O"
alias ROCK = "#"

alias Direction = UInt8
alias RIGHT: UInt8 = 0
alias DOWN: UInt8 = 1
alias LEFT: UInt8 = 2
alias UP: UInt8 = 3

alias Arr = List[_]
alias Items = List[Arr[Bool]]

alias StrWidth = 128
alias StrRealWidth = 100
alias StrSIMD = SIMD[DType.uint8, StrWidth]
alias `O` = StrSIMD(79)
alias `#` = StrSIMD(35)
alias `.` = StrSIMD(46)


fn parse_items(inout rocks: Items, inout rolls: Items, maze: List[String]):
    # for l in maze:
    #     smd = l[].unsafe_ptr().load[width=128]()
    #     rl = (smd == `O`)
    #     rk = (smd == `#`)

    #     print(smd)
    for i in range(len(maze)):
        for j in range(len(maze[0])):
            if maze[i][j] == ROCK:
                rocks[i][j] = 1
                continue
            if maze[i][j] == ROLL:
                rolls[i][j] = 1
    print("ok")


fn move[*DIR: Direction](rocks: Items, inout rolls: Items) -> UInt32:
    alias dirs = VariadicList(DIR)

    @parameter
    for di in range(len(dirs)):
        alias d = dirs[di]
        single_move[d](rocks, rolls)

    return calculate[dirs[0]](rolls)


@always_inline("nodebug")
fn single_move[DIR: Direction](rocks: Items, inout rolls: Items):
    pass


fn calculate[DIR: Direction](rolls: Items) -> UInt32:
    return 0


struct Solution(AdventSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        rolls = Items()
        rocks = rolls
        parse_items(rocks, rolls, lines)
        print("rocks:")
        for v in rocks:
            print(v[].__str__())
        print("rolls:")
        for v in rolls:
            print(v[].__str__())
        return move[UP](rocks, rolls)
        # return calculate[RIGHT](rolls)

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        rolls = Items()
        rocks = rolls
        parse_items(rocks, rolls, lines)

        # maze = lines

        cycles, iteration = 0, 0
        prev_rolls = InlineList[Int, 200]()
        # mazes = Dict[String, Int](power_of_two_initial_capacity=256)

        cycles = 0
        # idx = 0
        while True:
            val = move[UP, LEFT, DOWN, RIGHT](rocks, rolls)

            for ri in range(len(prev_rolls)):
                if prev_rolls[ri] == int(val):
                    iteration = len(prev_rolls)
                    cycles = iteration - ri
                    break

            if cycles:
                break

            prev_rolls.append(int(val))
            # possible = mazes.get("\n".join(maze))
            # if possible:
            #     idx = possible.value()
            #     iteration = len(mazes)
            #     cycles = iteration - idx
            #     break

            # mazes["\n".join(maze)] = idx
            # idx += 1

        valid_idx = (int(1e9) - iteration - 1) % cycles + (iteration - cycles)
        return prev_rolls[valid_idx]
        # for i in mazes.items():
        #     if i[].value == valid_idx:
        #         maze = i[].key.splitlines()
        #         break

        # return calculate[Direction.UP](maze)


# -------------- testing speed ------------------
# alias HORIZONTAL = [Direction.LEFT, Direction.RIGHT]
# alias POSITIVE = [Direction.RIGHT, Direction.DOWN]

# @register_passable("trivial")
# struct Direction:
#     alias UP = Self(1)
#     alias DOWN = Self(2)
#     alias LEFT = Self(3)
#     alias RIGHT = Self(4)
#     var _value: Int

#     fn __init__(out self, i: Int):
#         self._value = i

#     fn __eq__(self, other: Self) -> Bool:
#         return self._value == other._value

#     fn __ne__(self, other: Self) -> Bool:
#         return not self == other

# fn calculate[direction: Direction](maze: List[String]) -> Int:
#     alias positive = direction in POSITIVE
#     alias horizontal = direction in HORIZONTAL
#     max = len(maze[0]) if horizontal else maze.size
#     tot = 0
#     for r in range(maze.size):
#         for c in range(len(maze[r])):
#             if maze[r][c] == "O":
#                 val = c if horizontal else r
#                 final_val = val + 1 if positive else max - val
#                 tot += final_val
#     return tot


# fn tilt[times: Int = 1](inout maze: List[String]):
#     y_max = len(maze)
#     x_max = len(maze[0])
#     collection = maze

#     @parameter
#     for _ in range(times):

#         @parameter
#         fn calc_group(x: Int):
#             new_str = String(capacity=y_max)
#             count = 0
#             ly = y_max

#             for y in range(y_max - 1, -1, -1):
#                 if maze[y][x] == "#":
#                     new_str.write("." * (ly - y - 1 - count), "O" * count, "#")
#                     ly, count = y, 0

#                 elif maze[y][x] == "O":
#                     count += 1

#             new_str.write("." * (ly - count), "O" * count)
#             collection[x] = new_str

#         parallelize[calc_group](x_max)
#         maze = collection


# struct Solution(AdventSolution):
#     alias dtype = DType.int32

#     @staticmethod
#     fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
#         maze = lines
#         tilt[1](maze)
#         return calculate[Direction.RIGHT](maze)

#     @staticmethod
#     fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
#         maze = lines

#         cycles, iteration = 0, 0
#         mazes = Dict[String, Int](power_of_two_initial_capacity=256)

#         cycles = 0
#         idx = 0
#         while True:
#             tilt[4](maze)

#             possible = mazes.get("\n".join(maze))
#             if possible:
#                 idx = possible.value()
#                 iteration = len(mazes)
#                 cycles = iteration - idx
#                 break

#             mazes["\n".join(maze)] = idx
#             idx += 1

#         valid_idx = (int(1e9) - iteration - 1) % cycles + (iteration - cycles)
#         for i in mazes.items():
#             if i[].value == valid_idx:
#                 maze = i[].key.splitlines()
#                 break

#         return calculate[Direction.UP](maze)
