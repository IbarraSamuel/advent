from pathlib import Path
import benchmark
from solutions import Solutions
from pathlib import _dir_of_current_file
from testing import assert_equal
from builtin import Variadic
import sys


@register_passable("trivial")
struct Part[value: __mlir_type.`!pop.int_literal`](Equatable):
    comptime one = Part(1)
    comptime two = Part(2)

    comptime number = IntLiteral[Self.value]()

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
    comptime ms = TimeUnit("ms")
    comptime ns = TimeUnit("ns")
    comptime s = TimeUnit("s")

    comptime unit = StringLiteral[Self.value]()

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
    comptime T: Intable = Int32

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
        ...

    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
        ...


fn run[
    *solutions: AdventSolution
](input_path: StringSlice, day: Optional[Int], part: Optional[Int]) raises:
    var filepath = _dir_of_current_file() / "../.." / input_path
    comptime n_sols = Variadic.size(solutions)

    @parameter
    for i in range(n_sols):
        if day and day[] != i + 1:
            continue

        comptime Sol = solutions[i]

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
    var filepath = _dir_of_current_file() / "../.." / input_path
    comptime n_sols = Variadic.size(solutions)

    @parameter
    for i in range(n_sols):
        if day and day[] != i + 1:
            continue

        comptime Sol = solutions[i]

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


comptime HELP_STRING = """
Use `-m test` to run tests or `-m bench` to run benchmarks.
Defaults to -m run to just run and give the results back.

You can give an specific:
* Year with: `-y {YYYY}`. eg: `-y 2025`.
* Day with:  `-d {D|DD}`. eg: `-d 1` or `-d 25`.
* Part with: `-p {P}`.    eg: `-p 1`.

Any combination should work.
"""


@fieldwise_init
struct Args:
    comptime HELP = HELP_STRING

    var mode: String
    var year: Optional[Int]
    var day: Optional[Int]
    var part: Optional[Int]

    fn __init__(out self) raises:
        self = Self.parse_args()

    @staticmethod
    fn parse_args() raises -> Args:
        var args = sys.argv()

        var mode: StaticString = "run"
        var year: Optional[Int] = None
        var day: Optional[Int] = None
        var part: Optional[Int] = None

        for i, arg in enumerate(args):
            if String(arg) in ("-h", "--help"):
                raise Self.HELP

            if len(args) <= i + 1:
                break

            if String(arg) in ("-m", "--mode"):
                mode = args[i + 1]

            if String(arg) in ("-y", "--year"):
                year = Int(args[i + 1])

            if String(arg) in ("-d", "--day"):
                day = Int(args[i + 1])

            if String(arg) in ("-p", "--part"):
                part = Int(args[i + 1])

        return Args(mode=mode, year=year, day=day, part=part)
