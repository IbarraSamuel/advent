"""Utility functions for Advent of Code."""

from collections.abc import Sequence
from pathlib import Path
from typing import Protocol, override


class Stringable(Protocol):
    """Defines a type that could be converted to a string."""

    @override
    def __str__(self) -> str: ...


def read_input(path: str) -> list[str]:
    """Read input file into a polars DataFrame.

    Returns
    -------
    A list of strings.

    """
    with Path(path).open(encoding="utf-8") as f:
        return [s.strip() for s in f]


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
    print(f"From {path} =>")  # noqa: T201
    inp = read_input(path)
    day1 = result.part_1(inp)
    print(f"\tPart 1: {day1}")  # noqa: T201
    try:
        day2 = result.part_2(inp)
        print(f"\tPart 2: {day2}")  # noqa: T201
    except AttributeError:
        print("\tPart 2: NOT IMPLEMENTED")  # noqa: T201
