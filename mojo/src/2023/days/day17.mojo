from advent_utils import TensorSolution, FileTensor
from collections import Dict
from utils import IndexList, Index
import os

from time import sleep


@register_passable("trivial")
struct Dir(Writable):
    alias UP: Self = 1
    alias DOWN: Self = 2
    alias LEFT: Self = 3
    alias RIGHT: Self = 4
    var v: Int

    @implicit
    fn __init__(out self, v: Int):
        if 1 > v > 4:
            os.abort("not valid dir")
        self.v = v

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)

    fn write_to[W: Writer](self, mut writer: W):
        return writer.write(
            "UP" if self
            == Self.UP else "DOWN" if self
            == Self.DOWN else "LEFT" if self
            == Self.LEFT else "RIGHT"
        )


alias DUP: Pos = Pos(-1, 0)
alias DDOWN: Pos = Pos(1, 0)
alias DLEFT: Pos = Pos(0, -1)
alias DRIGHT: Pos = Pos(0, 1)

alias DIRS = List[Dir, True](Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.LEFT)
alias DIFS = List[Pos, True](DUP, DRIGHT, DDOWN, DLEFT)

alias Pos = IndexList[2]
alias CONST_OFFSET: Int = ord("0")


# IMPL


fn neighbours[
    linear: fn (Pos) capturing -> Int
](
    map: FileTensor, shape: (Int, Int), position: Pos, visited: List[Int]
) -> List[Int]:
    rows, cols = shape
    new_neighbours = List[Int]()
    for dif in DIFS:
        new_pos = position + dif[]
        if 0 <= new_pos[0] < cols and 0 <= new_pos[1] < rows:
            new_idx = linear(new_pos)
            if new_idx in visited:
                continue
            new_neighbours.append(new_idx)
    return new_neighbours


fn calc_costs(
    map: FileTensor,
    neighbours: List[Int],
    cur_cost: Int,
    mut costs: Dict[Int, Int],
) -> Int:
    lower_cost = Int.MAX
    lower_neighbour = neighbours[0]

    for n in neighbours:
        nb_cost = Int(map[n[]]) - CONST_OFFSET
        step_cost = cur_cost + nb_cost
        saved_cost = costs.get(n[], step_cost)
        real_cost = min(step_cost, saved_cost)
        costs[n[]] = real_cost

        if real_cost < lower_cost:
            lower_neighbour = n[]
            lower_cost = real_cost

    return lower_neighbour


fn _print_board[
    linear: fn (Pos) capturing -> Int
](shape: (Int, Int), map: FileTensor, visited: List[Int], current: Pos) -> None:
    for x in range(shape[1]):
        for y in range(shape[0]):
            if Pos(x, y) == current:
                print("#", end="")
            elif linear(Pos(x, y)) in visited:
                print("X", end="")
            else:
                print(map[Pos(x, y)] - CONST_OFFSET, end="")
        print()
    print()


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        """Each field could have 4 positions *  4 directions * 3 steps == 48."""
        """Final count will be 48 * 141 * 141 = 954288"""
        print(data)

        sp = data.shape()
        rows, cols = sp[0], sp[1] - 1
        shape = (rows, cols)

        @parameter
        fn linear(pos: Pos) -> Int:
            return data._compute_linear_offset(pos)

        @parameter
        fn toidx(pos: Int) -> Pos:
            return pos // (rows + 1), pos % (cols + 1)

        current = Pos(0, 0)
        lcurrent = linear(current)

        visited = List[Int](lcurrent)
        costs = Dict[Int, Int]()
        costs[lcurrent] = 0

        final = Pos(cols - 1, rows - 1)

        while len(visited) < rows * cols:
            sleep(0.1)
            nb = neighbours[linear](data, shape, current, visited)
            print(current)
            # This is temp
            print("[", end="")
            for p in nb:
                print(toidx(p[]), ", ", sep="", end="")
            print("]")
            # print(nb.__str__())
            _print_board[linear](shape, data, visited, current)
            if len(nb) == 0:
                # print("No neighbours.. current map:")
                # _print_board[linear](shape, data, visited, current)
                nv = lcurrent  # This is fake
                for ix in reversed(costs):
                    if ix[] not in visited:
                        nv = ix[]
                        break
                # nb = List()
                # os.abort("No neighbours.. current map:")
                # lower_cost = Int.MAX
                # lower_pos = 0
                # for tp in costs.items():
                #     if tp[].value < lower_cost and tp[].key not in visited:
                #         lower_pos = tp[].key

                nb = List(nv)

            lcurrent = calc_costs(data, nb, costs[lcurrent], costs)
            current = toidx(lcurrent)
            visited.append(lcurrent)
            # print(visited.__str__())
            # print(costs.__str__())

            # break

        return costs[linear(final)]

    @staticmethod
    fn part_2(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
