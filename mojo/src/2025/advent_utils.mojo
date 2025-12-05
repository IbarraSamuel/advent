from pathlib import Path
import benchmark
from pathlib import _dir_of_current_file
from testing import assert_equal
from builtin import Variadic


struct Solutions[*solutions: AdventSolution]:
    pass


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


fn run[
    *solutions: AdventSolution
](input_path: StringSlice, day: Optional[Int], part: Optional[Int]) raises:
    var filepath = _dir_of_current_file() / "../../.." / input_path
    alias n_sols = Variadic.size(solutions)

    @parameter
    for i in range(n_sols):
        if day and day[] != i + 1:
            continue

        alias Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = filepath / String("day", day, ".txt")
        var data = file.read_text().as_string_slice()

        print("Day", day, "=>")

        if not part or part[] == 1:
            var p1: Sol.T = Sol.part_1(data)
            print("\tPart 1:", Int(p1))

        if not part or part[] == 2:
            var p2: Sol.T = Sol.part_2(data)
            print("\tPart 2:", Int(p2), end="\n\n")


fn bench[
    iters: Int,
    time_unit: TimeUnit,
    *solutions: AdventSolution,
](input_path: StringSlice, day: Optional[Int], part: Optional[Int]) raises:
    var filepath = _dir_of_current_file() / "../../.." / input_path
    alias n_sols = Variadic.size(solutions)

    @parameter
    for i in range(n_sols):
        if day and day[] != i + 1:
            continue

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
        if not part or part[] == 1:
            print("Part 1:")
            benchmark.run[part_1](max_iters=iters).print(time_unit.unit)
        if not part or part[] == 2:
            print("Part 2:")
            benchmark.run[part_2](max_iters=iters).print(time_unit.unit)

        print()
