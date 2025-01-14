"""day02."""

MIN_DIF, MAX_DIF = 1, 3


class Solution:
    """Solution for day 02."""

    @staticmethod
    def part_1(data: str) -> int:
        """
        Part 1 solution.

        Returns
        -------
        The result.

        """
        lnums = (line.split() for line in data.splitlines())
        difs = [
            [int(nums[i]) - int(nums[i + 1]) for i in range(len(nums) - 1)]
            for nums in lnums
        ]
        return sum(
            all(MIN_DIF <= d <= MAX_DIF for d in difc)
            and (all(d < 0 for d in difc) or all(d > 0 for d in difc))
            for difc in difs
        )

    @staticmethod
    def part_2(data: str) -> int:
        """
        Part 2 solution.

        Returns
        -------
        The result.

        """
        lnums = (line.split() for line in data.splitlines())
        difs = [
            [int(nums[i]) - int(nums[i + 1]) for i in range(len(nums) - 1)]
            for nums in lnums
        ]
        return sum(
            all(MIN_DIF <= d <= MAX_DIF for d in difc)
            and (all(d < 0 for d in difc) or all(d > 0 for d in difc))
            for difc in difs
        )
