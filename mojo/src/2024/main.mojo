from advent_utils import run, bench
from sys import argv
import days


fn main() raises:
    """Use --bench flag to run benchmarks."""
    var args = argv()

    run[
        "inputs/2024",
        days.day01.Solution,
        days.day02.Solution,
        days.day03.Solution,
        days.day04.Solution,
    ]()

    do_bench = False
    for arg in args:
        if arg == "--bench":
            do_bench = True
            break

    if do_bench:
        bench[
            1000,
            "ms",
            "inputs/2024",
            days.day01.Solution,
            days.day02.Solution,
            days.day03.Solution,
            days.day04.Solution,
        ]()
