from python.advent_utils import read_input


def keep_numbers(line: str) -> str:
    return "".join([c for c in line if c.isdigit()])


def part_1() -> str:
    inp = read_input("inputs/day01.txt")
    only_numbers = [keep_numbers(line) for line in inp]
    total = sum(int(n[0] + n[-1]) for n in only_numbers)
    print(total)
    return str(total)


if __name__ == "__main__":
    part_1()
