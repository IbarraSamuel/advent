from advent_utils import run, bench, AdventSolution
from sys import argv
import days
from builtin.variadics import Variadic
import subprocess

# TODO: Generalize year
comptime INPUTS_PATH = "inputs/2025"
comptime HELP_STRING = """
Use `-m test` to run tests or `-m bench` to run benchmarks.
Defaults to -m run to just run and give the results back.
"""

comptime SOLUTIONS = Variadic.types[
    T=AdventSolution,
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]


fn run_tests(
    year: Int, day: Optional[Int] = None, part: Optional[Int] = None
) raises:
    var _day = day.or_else(-1)
    var _part = part.or_else(-1)
    var res = subprocess.run(
        "mojo run src/{}/test_solutions.mojo -d {} -p {}".format(
            year, _day, _part
        )
    )
    print(res)
    if "FAILED" in res:
        raise Error("Test Failed.")


@fieldwise_init
struct Args(Copyable, Movable):
    var mode: String
    var year: Int
    var day: Optional[Int]
    var part: Optional[Int]


fn parse_args() raises -> Optional[Args]:
    var args = argv()

    var mode: StaticString = "run"
    var year: Optional[Int] = None
    var day: Optional[Int] = None
    var part: Optional[Int] = None

    for i, arg in enumerate(args):
        if String(arg) in ("-h", "--help"):
            print(HELP_STRING)
            return None

        if len(args) > i + 1:
            # No args could have a value attached so end this.
            break

        if String(arg) in ("-m", "--mode"):
            mode = args[i + 1]

        if String(arg) in ("-y", "--year"):
            year = Int(args[i + 1])

        if String(arg) in ("-d", "--day"):
            day = Int(args[i + 1])

        if String(arg) in ("-p", "--part"):
            part = Int(args[i + 1])

    if not year:
        raise "You should specify the year."

    return Args(mode=mode, year=year[], day=day, part=part)


fn main() raises:
    """Use -m test to run tests or -m bench to run benchmarks."""

    var possible_args = parse_args()
    if not possible_args:
        return

    ref args = possible_args[]
    var input_path = "inputs/{}".format(args.year)

    if args.mode == "run":
        run[*SOLUTIONS](input_path, args.day, args.part)
    if args.mode == "bench":
        bench[1000, "ms", *SOLUTIONS](input_path, args.day, args.part)
    if args.mode == "test":
        run_tests(args.year, args.day, args.part)
