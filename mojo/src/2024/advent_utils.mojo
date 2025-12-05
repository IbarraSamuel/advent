from pathlib import Path
from benchmark import run as run_bench
from pathlib import _dir_of_current_file
from testing import assert_equal
from builtin import Variadic
from sys.intrinsics import _type_is_eq_parse_time


@register_passable("trivial")
struct Part[value: __mlir_type.`!pop.int_literal`](Equatable):
    alias one = Part(1)
    alias two = Part(2)

    alias number = IntLiteral[Self.value]()

    @implicit
    @always_inline("builtin")
    fn __init__(out self: Part[v.value], v: type_of(1)):
        pass

    @implicit
    @always_inline("builtin")
    fn __init__(out self: Part[v.value], v: type_of(2)):
        pass

    @always_inline("builtin")
    fn __eq__(self, other: Self) -> Bool:
        return True

    @always_inline("builtin")
    fn __eq__(self, other: Part) -> Bool:
        return self.number == other.number


@register_passable("trivial")
struct TimeUnit[value: __mlir_type.`!kgen.string`]:
    alias ms = TimeUnit("ms")
    alias ns = TimeUnit("ns")
    alias s = TimeUnit("s")

    alias unit = StringLiteral[Self.value]()

    @implicit
    @always_inline("builtin")
    fn __init__(out self: TimeUnit[v.value], v: type_of("ms")):
        pass

    @implicit
    @always_inline("builtin")
    fn __init__(out self: TimeUnit[v.value], v: type_of("ns")):
        pass

    @implicit
    @always_inline("builtin")
    fn __init__(out self: TimeUnit[v.value], v: type_of("s")):
        pass


trait AdventSolution:
    alias T: Intable = Int32

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
        ...

    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
        ...


fn run[input_path: StringLiteral, *solutions: AdventSolution]() raises:
    var filepath = _dir_of_current_file() / "../../.." / input_path
    alias n_sols = Variadic.size(solutions)

    @parameter
    for i in range(n_sols):
        alias Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = filepath / String("day", day, ".txt")
        var data = file.read_text().as_string_slice()

        var p1: Sol.T = Sol.part_1(data)
        var p2: Sol.T = Sol.part_2(data)

        print("Day", day, "=>")
        print("\tPart 1:", Int(p1))
        print("\tPart 2:", Int(p2), end="\n\n")


fn bench[
    iters: Int,
    time_unit: TimeUnit,
    input_path: StringLiteral,
    *solutions: AdventSolution,
]() raises:
    var filepath = _dir_of_current_file() / "../../.." / input_path
    alias n_sols = Variadic.size(solutions)

    @parameter
    for i in range(n_sols):
        alias Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = filepath / String("day", day, ".txt")
        var data = file.read_text().as_string_slice()

        @parameter
        fn part_1():
            _ = Sol.part_1(data)

        @parameter
        fn part_2():
            _ = Sol.part_2(data)

        print(">>> Day", day, "<<<")
        print("Part 1:")
        run_bench[part_1](max_iters=iters).print(time_unit.unit)
        print("Part 2:")
        run_bench[part_2](max_iters=iters).print(time_unit.unit)
        print()


fn test[
    S: AdventSolution,
    part: Part,
    file: StringLiteral,
    expected: IntLiteral,
]() raises:
    var filepath = _dir_of_current_file() / "../../.." / file
    var data = filepath.read_text().as_string_slice()

    @parameter
    if part == 1:
        var res = S.part_1(data)
        assert_equal(Int(res), expected)
    elif part == 2:
        var res = S.part_2(data)
        assert_equal(Int(res), expected)
