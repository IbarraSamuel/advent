from advent.advent_utils import read_input


def part_1() -> str:
    np = read_input("inputs/day1_1.txt", header=False)
    print(np)
    return np.__str__()


if __name__ == "__main__":
    part_1()
