"""Utils for 2024."""

from pathlib import Path
from typing import Protocol


class Solution(Protocol):
    """Protocol that defines a advent solution."""

    @staticmethod
    def part_1(data: str) -> int:
        """Part 1 solution."""
        ...

    @staticmethod
    def part_2(data: str) -> int:
        """Part 2 solution."""
        ...


def run(path: str, *solutions: Solution) -> None:
    """Run all solutions."""
    folder = Path(__file__).parent.parent.parent.parent / path

    for no, sol in enumerate(solutions, 1):
        day = f"{no:02d}"
        with (folder / f"day{day}.txt").open("rt") as f:
            data = f.read()
            print(f"From Day {day} =>")  # noqa: T201
            p1 = sol.part_1(data)
            print("\tPart 1:", p1)  # noqa: T201
            p2 = sol.part_2(data)
            print("\tPart 2:", p2, end="\n\n")  # noqa: T201
