import aoc2023, aoc2024, aoc2025
from advent_utils import AdventSolution
from builtin import Variadic

comptime Solutions2023 = Variadic.types[
    T=AdventSolution,
    aoc2023.day01.Solution,
    aoc2023.day02.Solution,
    aoc2023.day03.Solution,
    aoc2023.day04.Solution,
    aoc2023.day05.Solution,
    aoc2023.day06.Solution,
    aoc2023.day07.Solution,
    aoc2023.day08.Solution,
    aoc2023.day09.Solution,
    aoc2023.day10.Solution,
    aoc2023.day11.Solution,
    aoc2023.day12.Solution,
    aoc2023.day13.Solution,
    aoc2023.day14.Solution,
    aoc2023.day15.Solution,
    aoc2023.day16.Solution,
    aoc2023.day17.Solution,
]
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
]

comptime Solutions = [
    (2023, Solutions2023),
    (2024, Solutions2024),
    (2025, Solutions2025),
]
