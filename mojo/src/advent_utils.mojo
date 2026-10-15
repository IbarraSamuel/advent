from std.pathlib import Path
from std.benchmark import run as bench_run
from std.sys import argv
from motoml.mmap_file import MappedFile


__enum Part(ImplicitlyCopyable):
    case one
    case two


__enum TimeUnit(ImplicitlyCopyable):
    case ms
    case ns
    case s


trait AdventSolution:
    comptime T: Intable & Deinitable = Int32

    @staticmethod
    def part_1(data: StringSlice) -> Self.T:
        ...

    @staticmethod
    def part_2(data: StringSlice) -> Self.T:
        ...


def run[
    *solutions: AdventSolution
](input_dir: Path, day: Optional[Int], part: Optional[Part]) raises:
    comptime for i in range(solutions.length):
        match day:
            case .Some(d) if d != i + 1:
                continue
            case _:
                pass

        comptime Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = input_dir / "day{}.txt".format(day)
        var data = MappedFile(file).unsafe_view()

        print("Day", day, "=>")

        if case .None | .Some(.one) = part:
            var p1: Sol.T = Sol.part_1(data)
            print("\tPart 1:", Int(p1))

        if case .None | .Some(.two) = part:
            var p2: Sol.T = Sol.part_2(data)
            print("\tPart 2:", Int(p2), end="\n\n")


def bench[
    iters: Int,
    time_unit: TimeUnit,
    *solutions: AdventSolution,
](input_dir: Path, day: Optional[Int], part: Optional[Part]) raises:
    var unit: StaticString
    comptime match time_unit:
        case .ms:
            unit = "ms"
        case .ns:
            unit = "ns"
        case .s:
            unit = "s"

    comptime for i in range(solutions.length):
        match day:
            case .Some(v) if v != i + 1:
                continue
            case _:
                pass

        comptime Sol = solutions[i]

        var day = String("0" if i < 9 else "", i + 1)
        var file = input_dir / "day{}.txt".format(day)
        var data = file.read_text()

        def part_1() {imm}:
            _ = Sol.part_1(data)

        def part_2() {imm}:
            _ = Sol.part_2(data)

        print("Day", day, "=>")
        if case .None | .Some(.one) = part:
            var report = bench_run(part_1, max_iters=iters)
            var time = round(report.mean(unit) * 1e6) / 1e6
            print("\tPart 1:", time, unit)

        if case .None | .Some(.two) = part:
            var report = bench_run(part_2, max_iters=iters)
            var time = round(report.mean(unit) * 1e6) / 1e6
            print("\tPart 2:", time, unit)


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
    var part: Optional[Part]

    def __init__(out self) raises:
        self = Self.parse_args()

    @staticmethod
    def parse_args() raises -> Args:
        var args = argv()

        var mode: StaticString = "run"
        var year: Optional[Int] = None
        var day: Optional[Int] = None
        var part: Optional[Part] = None

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

                match Int(value):
                    case 1:
                        part = Part.one
                    case 2:
                        part = Part.two

        return Args(mode=mode, year=year, day=day, part=part)
