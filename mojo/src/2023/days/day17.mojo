from advent_utils import TensorSolution, FileTensor
from collections import Dict
from utils import IndexList, Index
import os


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
](map: FileTensor, position: Pos, visited: List[Int]) -> List[Int]:
    sp = map.shape()
    rows, cols = sp[0], sp[1]
    nl = List[Int]()
    for dif in DIFS:
        v1 = position + dif[]
        if 0 <= v1[0] < cols and 0 <= v1[1] < rows:
            lv = linear(v1)
            if lv in visited:
                continue
            nl.append(lv)
    return nl


fn calc_costs(
    map: FileTensor, nb: List[Int], cur_cost: Int, mut costs: Dict[Int, Int]
) -> Int:
    lower_cost = Int.MAX
    lower_neighbour = nb[0]

    for n in nb:
        nb_cost = Int(map[n[]]) - CONST_OFFSET
        real_cost = nb_cost + cur_cost
        costs[n[]] = real_cost

        if real_cost < lower_cost:
            lower_neighbour = n[]
            lower_cost = real_cost

    return lower_neighbour


fn _print_board[
    linear: fn (Pos) capturing -> Int
](shape: (Int, Int), map: FileTensor, visited: List[Int]) -> None:
    for x in range(shape[1]):
        for y in range(shape[0]):
            if linear(Pos(x, y)) in visited:
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

        sp = data.shape()
        rows, cols = sp[0], sp[1]

        @parameter
        fn linear(pos: Pos) -> Int:
            return data._compute_linear_offset(pos)

        @parameter
        fn toidx(pos: Int) -> Pos:
            return pos // (rows + 1), pos % cols

        current = Pos(0, 0)
        lcurrent = linear(current)

        visited = List[Int](lcurrent)
        costs = Dict[Int, Int]()
        costs[lcurrent] = 0

        final = Pos(cols - 1, rows - 1)

        while current != final:
            print(current)
            nb = neighbours[linear](data, current, visited)
            print(nb.__str__())
            if len(nb) == 0:
                print("No neighbours.. current map:")
                _print_board[linear]((rows, cols), data, visited)
                lower_cost = Int.MAX
                lower_pos = 0
                for tp in costs.items():
                    if tp[].value < lower_cost and tp[].key not in visited:
                        lower_pos = tp[].key

                nb = List(lower_pos)

            lcurrent = calc_costs(data, nb, costs[lcurrent], costs)
            current = toidx(lcurrent)
            visited.append(lcurrent)
            # print(visited.__str__())
            # print(costs.__str__())

            # break

        return costs[lcurrent]

    @staticmethod
    fn part_2(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        return 0
