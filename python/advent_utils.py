"""Utility functions for Advent of Code."""

from collections.abc import Sequence
from pathlib import Path
from typing import Protocol, TypeVar, override


class Stringable(Protocol):
    @override
    def __str__(self) -> str: ...


T_co = TypeVar("T_co", covariant=True)


def read_input(path: str) -> list[str]:
    """Read input file into a polars DataFrame."""
    with Path(path).open() as f:
        return f.readlines()


class AdventSolution(Protocol):
    """Represents a result of an Advent of Code problem."""

    @staticmethod
    def part_1(lines: Sequence[str]) -> Stringable:
        """Return the solution for day 1."""
        ...

    @staticmethod
    def part_2(lines: Sequence[str]) -> Stringable:
        """Return the solution for day 2."""
        ...


def run(result: type[AdventSolution], path: str) -> None:
    """Run the solution for a given day."""
    print(f"From {path} =>")
    inp = read_input(path)
    day1 = result.part_1(inp)
    print(f"\tPart 1: {day1}")
    try:
        day2 = result.part_2(inp)
        print(f"Part 2: {day2}")
    except AttributeError:
        print("Part 2: NOT IMPLEMENTED")
