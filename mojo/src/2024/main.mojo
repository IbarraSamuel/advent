from advent_utils import run, bench
from sys import argv
import days
import subprocess

comptime HELP_STRING = """
Use `-m test` to run tests or `-m bench` to run benchmarks.
Defaults to -m run to just run and give the results back.
"""

comptime HELP_ARGS = ("help", "--help", "-h")
comptime MODE_ARGS = ("--mode", "-m")

comptime run_ = run[
    "inputs/2024",
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]

comptime bench_ = bench[
    1000,
    "ms",
    "inputs/2024",
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]


fn test_() raises:
    res = subprocess.run("mojo run src/2024/test_solutions.mojo")
    print(res)
    if "FAILED" in res:
        raise Error("Test Failed.")


fn main() raises:
    """Use -m test to run tests or -m bench to run benchmarks."""
    var args = argv()

    var mode: StaticString = "run"

    for i, arg in enumerate(args):
        if String(arg) in HELP_ARGS:
            print(HELP_STRING)
            return

        if String(arg) in MODE_ARGS and len(args) > i + 1:
            mode = args[i + 1]

    if mode == "run":
        run_()
    if mode == "bench":
        bench_()
    if mode == "test":
        test_()
