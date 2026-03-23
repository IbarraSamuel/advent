"""2024 solutions."""

from typing import TYPE_CHECKING

from . import days

if TYPE_CHECKING:
    from advent.advent_utils import Solution

solutions: tuple[Solution, ...] = (days.day01.Solution, days.day02.Solution)
