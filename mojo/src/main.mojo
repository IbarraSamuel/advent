from advent_utils import run, bench, Args, HELP_STRING
from test_solutions import run_tests, parse_config
from testing import TestSuite
from solutions import Solutions


fn main() raises:
    """Use -m test to run tests or -m bench to run benchmarks."""

    var config = parse_config()
    try:
        args = Args()
    except e:
        if String(e) == HELP_STRING:
            print(e)
            return
        raise e

    @parameter
    for Solution in Solutions:
        comptime Y, S = Solution
        if args.year and args.year[] != Y:
            continue

        var input_path = "inputs/{}".format(Y)
        print("<==", Y, "==>")
        if args.mode == "run":
            run[*S](input_path, args.day, args.part)
        elif args.mode == "bench":
            bench[1000, "ms", *S](input_path, args.day, args.part)
        elif args.mode == "test":
            run_tests[Y, *S](args, config)
