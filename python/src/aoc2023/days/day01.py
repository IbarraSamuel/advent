"""Day 1 result."""

import operator
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


def _filter_digit_chars(line: str) -> str:
    return "".join([c for c in line if c.isdigit()])


class Solution:
    """Solution for the first day."""

    @staticmethod
    def part_1(lines: Sequence[str]) -> int:
        """Solution for part 1.

        Returns
        -------
        the result of part 1.

        """
        only_numbers = [_filter_digit_chars(line) for line in lines]
        return sum(int(n[0] + n[-1]) for n in only_numbers)

    @staticmethod
    def part_2(lines: Sequence[str]) -> int:
        """Solution for part 2.

        Returns
        -------
        The result of part 2

        """
        total = 0
        for line in lines:
            first, _ = min(
                ((a, line.find(a)) for a in IM if a in line),
                key=operator.itemgetter(1),
            )
            last, _ = max(
                ((a, line.rfind(a)) for a in IM if a in line),
                key=operator.itemgetter(1),
            )
            total += IM[first] * 10 + IM[last]
        return total
