from .advent_utils import run
from .days import day01


def main() -> None:
    run(day01.Solution, "../inputs/day01.txt")


if __name__ == "__main__":
    main()
