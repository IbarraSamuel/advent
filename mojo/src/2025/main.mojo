from advent_utils import run, bench, YEAR, AdventSolution
from sys import argv
import days
from builtin.variadics import MakeVariadic, VariadicOf
import subprocess

comptime INPUTS_PATH = "inputs/" + YEAR
comptime HELP_STRING = """
Use `-m test` to run tests or `-m bench` to run benchmarks.
Defaults to -m run to just run and give the results back.
"""

comptime HELP_ARGS = ("help", "--help", "-h")
comptime MODE_ARGS = ("--mode", "-m")

comptime SOLUTIONS = MakeVariadic[
    T=AdventSolution,
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]
comptime run_ = run[INPUTS_PATH, *SOLUTIONS]

comptime bench_ = bench[1000, "ms", INPUTS_PATH, *SOLUTIONS]


fn test_() raises:
    res = subprocess.run("mojo run src/" + YEAR + "/test_solutions.mojo")
    print(res)
    if "FAILED" in res:
        raise Error("Test Failed.")


@fieldwise_init
struct Args(Copyable, Movable):
    var mode: String


fn parse_args() raises -> Optional[Args]:
    var args = argv()

    var mode: StaticString = "run"

    for i, arg in enumerate(args):
        if String(arg) in HELP_ARGS:
            print(HELP_STRING)
            return None

        if String(arg) in MODE_ARGS and len(args) > i + 1:
            mode = args[i + 1]

    return Args(mode=mode)


fn main() raises:
    """Use -m test to run tests or -m bench to run benchmarks."""

    var possible_args = parse_args()
    if not possible_args:
        return

    ref args = possible_args[]
    if args.mode == "run":
        run_()
    if args.mode == "bench":
        bench_()
    if args.mode == "test":
        test_()
