import aoc2023, aoc2024, aoc2025
from advent_utils import AdventSolution
from std.builtin.rebind import downcast

comptime Years = ParameterList.of[2023, 2024, 2025]()


trait ASolution:
    comptime Year: Int
    comptime Solution: AdventSolution


struct YearSolution[Y: Int, S: AdventSolution](ASolution):
    comptime Year = Self.Y
    comptime Solution = Self.S


comptime WithYear[Y: Int, Sol: AdventSolution]: ASolution = YearSolution[Y, Sol]

comptime Solutions = TypeList._concat[
    aoc2023.Solutions2023.map[WithYear[2023, _]].values,
    aoc2024.Solutions2024.map[WithYear[2024, _]].values,
    aoc2025.Solutions2025.map[WithYear[2025, _]].values,
]

comptime ForYear[Y: Int, AS: ASolution, _Idx: Int]: Bool = AS.Year == Y
comptime GetSolution[AS: ASolution]: AdventSolution = AS.Solution

comptime SolutionsForYear[Y: Int] = Solutions.filter_idx[ForYear[Y, ...]].map[
    GetSolution
]
