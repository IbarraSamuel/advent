"""Program entrypoint."""

from .advent_utils import run  # ty:ignore[unresolved-import]
from .days import day01  # ty:ignore[unresolved-import]


def main() -> None:
    """Entrypoint."""
    run("inputs/2025/", day01.Solution)


if __name__ == "__main__":
    main()
