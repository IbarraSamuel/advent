from std.pathlib import Path
import std.benchmark as benchmark
from std.pathlib import _dir_of_current_file
from std.testing import assert_equal
from std.sys import argv


__enum Part:
    case one
    case two

    # struct Part(EnumLike, TrivialRegisterPassable):
    #     comptime one = Part(1)
    #     comptime two = Part(2)

    #     var number: Int

    #     comptime _enum_case_names = ParameterList.of[
    #         "one".value, "two".value
    #     ].values
    #     comptime _enum_case_types = TypeList.splat[count=2, type=Self].values

    #     def _get_enum_discriminant(self) -> Int:
    #         return self.number - 1

    #     def _unsafe_get_enum_payload[
    #         id: Int
    #     ](ref self) -> ref[self] TypeList[Trait=AnyType, Self._enum_case_types]()[
    #         id
    #     ]:
    #         while True:
    #             pass

    # @implicit
    # @always_inline("builtin")
    # def __init__(out self, v: type_of(1)):
    #     self.number = v

    # @implicit
    # @always_inline("builtin")
    # def __init__(out self, v: type_of(2)):
    #     self.number = v


struct TimeUnit(EnumLike, TrivialRegisterPassable):
    comptime ms = TimeUnit("ms")
    comptime ns = TimeUnit("ns")
    comptime s = TimeUnit("s")

    var unit: StaticString

    comptime _enum_case_names = ParameterList.of[
        "ms".value, "ns".value, "s".value
    ].values
    comptime _enum_case_types = TypeList.splat[count=2, type=Self].values

    def _get_enum_discriminant(self) -> Int:
        return 0 if self.unit == "ms" else 1 if self.unit == "ns" else 2

    def _unsafe_get_enum_payload[
        id: Int
    ](ref self) -> ref[self] TypeList[Trait=AnyType, Self._enum_case_types]()[
        id
    ]:
        while True:
            pass

    @implicit
    def __init__(out self, v: type_of("ms")):
        self.unit = v

    @implicit
    def __init__(out self, v: type_of("ns")):
        self.unit = v

    @implicit
    def __init__(out self, v: type_of("s")):
        self.unit = v


# @fieldwise_init
# struct AdventSolution[
#     o: ImmutOrigin,
#     //,
#     part_1: def(StringSlice[o]) thin -> Int,
#     part_2: def(StringSlice[o]) thin -> Int,
# ]:
#     pass


# def part_a[o: ImmutOrigin](v: StringSlice[o]) -> Int:
#     return 1


# def part_b[o: ImmutOrigin](v: StringSlice[o]) -> Int:
#     return 2


# def generate_sol[o: ImmutOrigin]() -> AdventSolution[o=o, part_a[o], part_b[o]]:
#     return {}


trait AdventSolution:
    comptime T: Intable & Deinitable = Int32

    @staticmethod
    def part_1(data: StringSlice) -> Self.T:
        ...

    @staticmethod
    def part_2(data: StringSlice) -> Self.T:
        ...


# # TODO: Change when Generic Traits are available.
# trait AdventSolution2023(Defaultable):
#     comptime Year = 2023


# trait AdventSolution2024(Defaultable):
#     comptime Year = 2024


# trait AdventSolution2025(Defaultable):
#     comptime Year = 2025


def run[
    *solutions: AdventSolution
](input_dir: Path, day: Optional[Int], part: Optional[Int]) raises:
    comptime for i in range(solutions.length):
        if day and day.unsafe_value() != i + 1:
            continue

        comptime Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = input_dir / "day{}.txt".format(day)
        var data = file.read_text()

        print("Day", day, "=>")

        if not part or part.unsafe_value() == 1:
            var p1: Sol.T = Sol.part_1(data)
            print("\tPart 1:", Int(p1))

        if not part or part.unsafe_value() == 2:
            var p2: Sol.T = Sol.part_2(data)
            print("\tPart 2:", Int(p2), end="\n\n")


def bench[
    iters: Int,
    time_unit: TimeUnit,
    *solutions: AdventSolution,
](input_dir: Path, day: Optional[Int], part: Optional[Int]) raises:
    comptime for i in range(solutions.length):
        if day and day.unsafe_value() != i + 1:
            continue

        comptime Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = input_dir / "day{}.txt".format(day)
        var data = file.read_text()

        def part_1() {imm}:
            _ = Sol.part_1(data)

        def part_2() {imm}:
            _ = Sol.part_2(data)

        print("Day", day, "=>")
        if not part or part.unsafe_value() == 1:
            var report = benchmark.run(part_1, max_iters=iters)
            var time = round(report.mean(time_unit.unit) * 1e6) / 1e6
            print("\tPart 1:", time, time_unit.unit)

        if not part or part.unsafe_value() == 2:
            var report = benchmark.run(part_2, max_iters=iters)
            var time = round(report.mean(time_unit.unit) * 1e6) / 1e6
            print("\tPart 2:", time, time_unit.unit)


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
struct Help(TrivialRegisterPassable, Writable):
    comptime HELP = HELP_STRING

    def write_to(self, mut w: Some[Writer]):
        w.write(Self.HELP)


@fieldwise_init
struct Args(Writable):
    comptime HELP = HELP_STRING

    var mode: String
    var year: Optional[Int]
    var day: Optional[Int]
    var part: Optional[Int]

    def __init__(out self) raises:
        self = Self.parse_args()

    @staticmethod
    def parse_args() raises -> Args:
        var args = argv()

        var mode: StaticString = "run"
        var year: Optional[Int] = None
        var day: Optional[Int] = None
        var part: Optional[Int] = None

        for i, arg in enumerate(args):
            if String(arg) in ("-h", "--help"):
                print(Self.HELP)
                raise Help()

            if len(args) <= i + 1:
                break

            if String(arg) in ("-m", "--mode"):
                var value = args[i + 1]
                if String(value) not in ("run", "test", "bench"):
                    raise 'Mode should be one of these values: {"run", "test", "bench"}'
                mode = value

            if String(arg) in ("-y", "--year"):
                var value = args[i + 1]
                if not value.is_ascii_digit():
                    raise "Year should be an ascii digit."
                year = Int(value)

            if String(arg) in ("-d", "--day"):
                var value = args[i + 1]
                if not value.is_ascii_digit():
                    raise "Day should be an ascii digit."
                day = Int(value)

            if String(arg) in ("-p", "--part"):
                var value = args[i + 1]
                if not value.is_ascii_digit():
                    raise "Part should be an ascii digit."
                part = Int(value)

        return Args(mode=mode, year=year, day=day, part=part)
