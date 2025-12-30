"""Program entrypoint."""

from .advent_utils import run  # ty:ignore[unresolved-import]
from .days import day01, day02  # ty:ignore[unresolved-import]


def main() -> None:
    """Entrypoint."""
    run("inputs/2024/", day01.Solution, day02.Solution)


if __name__ == "__main__":
    main()
