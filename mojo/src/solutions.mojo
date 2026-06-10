import aoc2023, aoc2024, aoc2025
from advent_utils import AdventSolution
from std.builtin.rebind import downcast

comptime Years = ParameterList.of[2023, 2024, 2025]()

comptime Solutions2023 = TypeList.of[
    Trait=AdventSolution,
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
]
comptime Solutions2024 = TypeList.of[
    Trait=AdventSolution,
    aoc2024.day01.Solution,
    aoc2024.day02.Solution,
    aoc2024.day03.Solution,
    aoc2024.day04.Solution,
    aoc2024.day05.Solution,
]
comptime Solutions2025 = TypeList.of[
    Trait=AdventSolution,
    aoc2025.day01.Solution,
]


trait ASolution:
    comptime Year: Int
    comptime Solution: AdventSolution


struct YearSolution[Y: Int, S: AdventSolution](ASolution):
    comptime Year = Self.Y
    comptime Solution = Self.S


comptime WithYear[Y: Int, Sol: AdventSolution]: ASolution = YearSolution[Y, Sol]

comptime Solutions = TypeList._concat[
    Solutions2023.map[WithYear[2023, _]].values,
    Solutions2024.map[WithYear[2024, _]].values,
    Solutions2025.map[WithYear[2025, _]].values,
]

comptime ForYear[Y: Int, AS: ASolution, _Idx: Int]: Bool = AS.Year == Y
comptime GetSolution[AS: ASolution]: AdventSolution = AS.Solution

comptime SolutionsForYear[Y: Int] = Solutions.filter_idx[ForYear[Y, ...]].map[
    GetSolution
]
