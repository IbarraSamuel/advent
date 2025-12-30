"""Day 1 solution."""


class Solution:
    """Solution."""

    @staticmethod
    def part_1(data: str) -> int:
        """Day 1 solution.

        ```python3
        >>> from advent_utils import test
        >>> test("tests/2024/day01.txt", Solution, 1)
        11

        ```

        Returns
        -------
        The result

        """
        nums = [[int(num) for num in line.split()] for line in data.splitlines()]
        return sum(
            abs(a - b)
            for a, b in zip(
                sorted(a for a, _ in nums), sorted(b for _, b in nums), strict=False,
            )
        )

    @staticmethod
    def part_2(data: str) -> int:
        """Day 2 solution.

        ```python3
        >>> from advent_utils import test
        >>> test("tests/2024/day01.txt", solution, 2)
        31

        Returns
        -------
        The result

        """
        nums = [[int(num) for num in line.split()] for line in data.splitlines()]
        return sum(a * len([b for _, b in nums if b == a]) for a, _ in nums)
