"""Day 1 solution."""


class Solution:
    """Solution."""

    @staticmethod
    def part_1(data: str) -> int:
        """
        Day 1 solution.

        Returns
        -------
        The result

        """
        nums = [[int(num) for num in line.split()] for line in data.splitlines()]
        return sum(
            abs(a - b)
            for a, b in zip(
                sorted(a for a, _ in nums), sorted(b for _, b in nums), strict=False
            )
        )

    @staticmethod
    def part_2(data: str) -> int:
        """
        Day 2 solution.

        Returns
        -------
        The result

        """
        nums = [[int(num) for num in line.split()] for line in data.splitlines()]
        return sum(a * len([b for _, b in nums if b == a]) for a, _ in nums)
