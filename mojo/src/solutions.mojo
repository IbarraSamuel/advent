import aoc2024, aoc2025
from advent_utils import AdventSolution
from builtin import Variadic

comptime Solutions2024 = Variadic.types[
    T=AdventSolution,
    aoc2024.day01.Solution,
    aoc2024.day02.Solution,
    aoc2024.day03.Solution,
    aoc2024.day04.Solution,
    aoc2024.day05.Solution,
]
comptime Solutions2025 = Variadic.types[
    T=AdventSolution,
    aoc2025.day01.Solution,
    aoc2025.day02.Solution,
    aoc2025.day03.Solution,
    aoc2025.day04.Solution,
    aoc2025.day05.Solution,
]

comptime Solutions = [(2024, Solutions2024), (2025, Solutions2025)]
