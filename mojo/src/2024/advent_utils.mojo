from pathlib import Path
from time import perf_counter_ns
from pathlib import _dir_of_current_file
from testing import assert_equal


@register_passable("trivial")
struct Part(EqualityComparable):
    alias one: Part = 1
    alias two: Part = 2
    alias bad: Part = -1
    var v: Int

    @implicit
    @always_inline("builtin")
    fn __init__(out self, v: IntLiteral):
        self.v = v if v == 1 or v == 2 else -1

    @always_inline("builtin")
    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    @always_inline("builtin")
    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


trait AdventSolution:
    alias T: Intable

    @staticmethod
    fn part_1(data: StringSlice) -> T:
        ...

    @staticmethod
    fn part_2(data: StringSlice) -> T:
        ...


fn run[input_path: StringLiteral, *solutions: AdventSolution]() raises:
    var filepath = _dir_of_current_file() / "../../.." / input_path
    alias sols = VariadicList(solutions)
    alias n_sols = len(sols)

    @parameter
    for i in range(n_sols):
        alias Sol = solutions[i]

        day = String("0" if i < 9 else "", i + 1)
        file = filepath / String("day", day, ".txt")
        data = file.read_text().as_string_slice()

        init = perf_counter_ns()
        p1 = Sol.part_1(data)
        end = perf_counter_ns()
        b1 = end - init

        init = perf_counter_ns()
        p2 = Sol.part_2(data)
        end = perf_counter_ns()
        b2 = end - init

        # Saving results
        b1m = (b1 // 100) / 10
        b2m = (b2 // 100) / 10

        print("Day", day, "=>")
        print("\tPart 1:", Int(p1), "in", b1m, "us.")
        print("\tPart 2:", Int(p2), "in", b2m, "us.\n")


fn test[
    S: AdventSolution,
    part: Part,
    file: StringLiteral,
    expected: IntLiteral,
]() raises:
    var filepath = _dir_of_current_file() / "../../.." / file
    data = filepath.read_text().as_string_slice()

    @parameter
    if part == Part.one:
        res = S.part_1(data)
    elif part == Part.two:
        res = S.part_2(data)
    else:
        raise Error("Part argument is incorrectly set.")

    assert_equal(Int(res), expected)
