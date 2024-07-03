"""Day 1 result."""

from collections.abc import Sequence

IM = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
    "1": 1,
    "2": 2,
    "3": 3,
    "4": 4,
    "5": 5,
    "6": 6,
    "7": 7,
    "8": 8,
    "9": 9,
}


def _keep_numbers(line: str) -> str:
    return "".join([c for c in line if c.isdigit()])


class Solution:
    """Solution for the first day."""

    @staticmethod
    def part_1(lines: Sequence[str]) -> int:
        """Day 1 result."""
        only_numbers = [_keep_numbers(line) for line in lines]
        return sum(int(n[0] + n[-1]) for n in only_numbers)

    @staticmethod
    def part_2(lines: Sequence[str]) -> int:
        """Day 2 result."""
        total = 0
        for line in lines:
            first, _ = min(
                ((a, line.find(a)) for a in IM if a in line),
                key=lambda x: x[1],
            )
            last, _ = max(
                ((a, line.rfind(a)) for a in IM if a in line),
                key=lambda x: x[1],
            )
            total += IM[first] * 10 + IM[last]
        return total
