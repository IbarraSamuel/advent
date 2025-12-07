import days
from advent_utils import AdventSolution
from builtin import Variadic

comptime Solutions2024 = Variadic.types[
    T=AdventSolution,
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]
comptime Solutions2025 = Variadic.types[
    T=AdventSolution,
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]

comptime Solutions = [(2024, Solutions2024), (2025, Solutions2025)]
