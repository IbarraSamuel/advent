"""Utility functions for Advent of Code."""

from pathlib import Path
from typing import Protocol, Sequence, TypeVar

T_co = TypeVar("T_co", covariant=True)


def read_input(path: str) -> list[str]:
    """Read input file into a polars DataFrame."""
    with Path(path).open() as f:
        return f.readlines()


class AdventResult(Protocol[T_co]):
    """Represents a result of an Advent of Code problem."""

    @staticmethod
    def day_1(lines: Sequence[str]) -> T_co:
        """Return the solution for day 1."""
        ...

    @staticmethod
    def day_2(lines: Sequence[str]) -> T_co:
        """Return the solution for day 2."""
        ...


def run[T](result: type[AdventResult[T]], path: str) -> None:
    """Run the solution for a given day."""
    lines = read_input(path)
    print("day 1:", result.day_1(lines))
    print("day 2:", result.day_2(lines))
