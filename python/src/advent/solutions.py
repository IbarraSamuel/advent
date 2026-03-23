"""Collect all solutions."""

from typing import TYPE_CHECKING

from advent import aoc2023, aoc2024, aoc2025

if TYPE_CHECKING:
    from advent.advent_utils import Solution

SOLUTIONS_2023 = ((2023, s) for s in aoc2023.solutions)
SOLUTIONS_2024 = ((2024, s) for s in aoc2024.solutions)
SOLUTIONS_2025 = ((2025, s) for s in aoc2025.solutions)

SOLUTIONS: list[tuple[int, Solution]] = [
    *SOLUTIONS_2023,
    *SOLUTIONS_2024,
    *SOLUTIONS_2025,
]
