from advent_utils import run, bench, AdventSolution, parse_args, HELP_STRING
from solutions import Solutions
import days
from builtin.variadics import Variadic
import subprocess


comptime SOLUTIONS = Variadic.types[
    T=AdventSolution,
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]


fn run_tests(
    year: Optional[Int], day: Optional[Int] = None, part: Optional[Int] = None
) raises:
    var _day = day.or_else(-1)
    var _part = part.or_else(-1)
    # TODO: when moving to generic one, remove 2025
    var cmd = "mojo src/test_solutions.mojo"
    if year:
        cmd.write(" -y {}".format(year[]))
    if day:
        cmd.write(" -d {}".format(day[]))
    if part:
        cmd.write(" -p {}".format(part[]))
    var res = subprocess.run(cmd)
    print(res)
    if "FAILED" in res:
        raise "Test Failed."


fn main() raises:
    """Use -m test to run tests or -m bench to run benchmarks."""

    try:
        args = parse_args()
    except e:
        if String(e) == HELP_STRING:
            print(e)
            return
        raise e

    if args.mode == "test":
        run_tests(args.year, args.day, args.part)

    @parameter
    for Solution in Solutions:
        alias Y, S = Solution
        if not args.year or args.year[] == Y:
            var input_path = "inputs/{}".format(Y)
            print("<==", Y, "==>")
            if args.mode == "run":
                run[*S](input_path, args.day, args.part)
            if args.mode == "bench":
                bench[1000, "ms", *S](input_path, args.day, args.part)
