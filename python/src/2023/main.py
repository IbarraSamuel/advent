"""Program Entrypoint."""

from .advent_utils import run
from .days import day01, day02, day12


def main() -> None:
    """Each day should be added here."""
    run(day01.Solution, "../inputs/day01.txt")
    run(day02.Solution, "../inputs/day02.txt")
    run(day12.Solution, "../inputs/day12.txt")


if __name__ == "__main__":
    main()
