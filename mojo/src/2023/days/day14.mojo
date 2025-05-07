# from advent_utils import TensorSolution
# from algorithm import parallelize, vectorize
# from collections import Dict, InlineList, InlineArray
# from utils import StaticTuple, Index
# from max.tensor import Tensor

# import os
# from memory import UnsafePointer

# alias ROLL = "O"
# alias ROCK = "#"

# alias Direction = Int
# alias RIGHT: Direction = 0
# alias DOWN: Direction = 1
# alias LEFT: Direction = 2
# alias UP: Direction = 3

# alias Arr = List[_]
# alias Items = List[Arr[Bool]]

# alias LineWidth = 128
# alias AllPtr = LineWidth * LineWidth
# alias Side = 100
# alias STensor = Tensor[DType.uint8]

# alias RollOrd = 79
# alias RockOrd = 35
# alias SpaceOrd = 46

# alias EmptySIMD = SIMD[DType.uint8, AllPtr](0)
# alias RockSIMD = SIMD[DType.uint8, AllPtr](RockOrd)
# alias RollSIMD = SIMD[DType.uint8, AllPtr](RollOrd)
# alias SpaceSIMD = SIMD[DType.uint8, AllPtr](SpaceOrd)

# alias Position = (Int, Int)


# fn parse_items(ref maze: Tensor[DType.uint8]) -> (STensor, STensor):
#     """Returns a Tensor of rocks and rolls."""
#     m = maze.unsafe_ptr().load[width=AllPtr]()
#     rk = (m == RockSIMD).cast[DType.uint8]()
#     rl = (m == RollSIMD).cast[DType.uint8]()
#     k = Tensor[DType.uint8](maze.shape())
#     l = Tensor[DType.uint8](maze.shape())
#     k.store[width=AllPtr](0, val=rk)
#     l.store[width=AllPtr](0, val=rl)

#     print(k, l, sep="\n")

#     return k, l


# fn move[*DIR: Direction](rocks: STensor, mut rolls: STensor) -> UInt32:
#     alias dirs = VariadicList(DIR)

#     @parameter
#     for di in range(len(dirs)):
#         alias d = dirs[di]
#         single_move[d](rocks, rolls)

#     return calculate[dirs[0]](rolls)


# # @always_inline("nodebug")
# fn single_move[DIR: Direction](rocks_list: STensor, mut rolls: STensor):
#     # rk = rocks_list[0] if DIR in [UP, DOWN] else rocks_list[1]
#     # dir = 1 if DIR in [DOWN, RIGHT] else -1

#     # @parameter
#     # fn calc_line(x: Int):
#     #     for y in rk:
#     #         rline = rolls.load[width = Side + 1](Index(y[], 0))
#     #         rocks = rk.get(y[]).value()
#     #         p = 0
#     #         for x in rocks:
#     #             tot = (rline < x[] and rline > p).reduce_bit_count()
#     #             for tx in range(p, x[]):
#     #                 rolls[Index(y[], tx)] = 0 if tx < x[] - tot - 1 else 1

#     # parallelize[calc_line](Side + 1)
#     print("failing on single move")


# fn calculate[DIR: Direction](rolls: STensor) -> UInt32:
#     return 0


# struct Solution(TensorSolution):
#     alias dtype = DType.uint32

#     @staticmethod
#     fn part_1(owned data: Tensor[DType.uint8]) raises -> Scalar[Self.dtype]:
#         print(data)
#         print()
#         data.ireshape((Side, Side + 1))

#         rolls, rocks = parse_items(data)
#         # rocks_list = calc_rock_positions(rocks)
#         return move[UP](rocks, rolls)
#         # return calculate[RIGHT](rolls)

#     @staticmethod
#     fn part_2(owned data: Tensor[DType.uint8]) raises -> Scalar[Self.dtype]:
#         data.ireshape((Side, Side + 1))
#         rocks, rolls = parse_items(data)
#         # rocks_list = calc_rock_positions(rocks)

#         cycles, iteration = 0, 0
#         prev_rolls = List[Int]()

#         cycles = 0
#         while True:
#             val = move[UP, LEFT, DOWN, RIGHT](rocks, rolls)

#             for ri in range(len(prev_rolls)):
#                 if prev_rolls[ri] == int(val):
#                     iteration = len(prev_rolls)
#                     cycles = iteration - ri
#                     break

#             if cycles:
#                 break

#             prev_rolls.append(int(val))
#         valid_idx = (int(1e9) - iteration - 1) % cycles + (iteration - cycles)
#         return prev_rolls[valid_idx]


# -------------- testing speed ------------------
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
            lines[x] = line^

        parallelize[calc_line](x_max)
        maze = StringSlice("").join(lines^)


struct Solution(ListSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        maze = StringSlice("\n").join(lines) + "\n"
        tilt[1](maze)
        return calculate[RIGHT](maze)

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        maze = StringSlice("\n").join(lines) + "\n"
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
        for i in mazes.items():
            if i[].value == valid_idx:
                maze = i[].key
                break

        return calculate[UP](maze)
