"""Program entrypoint."""

from advent_utils import run
from days import day01, day02


def main() -> None:
    """Entrypoint."""
    run("inputs/2024/", day01.Solution, day02.Solution)


if __name__ == "__main__":
    main()
