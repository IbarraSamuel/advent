"""day02."""

MIN_DIF, MAX_DIF = 1, 3


class Solution:
    """Solution for day 02."""

    @staticmethod
    def part_1(data: str) -> int:
        """
        Part 1 solution.

        ```python3
        >>> f = open("../tests/2024/day02.txt")
        >>> Solution.part_1(f.read())
        2

        ```

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
            all(MIN_DIF <= abs(d) <= MAX_DIF for d in difc)
            and (all(d < 0 for d in difc) or all(d > 0 for d in difc))
            for difc in difs
        )

    @staticmethod
    def part_2(data: str) -> int:
        """
        Part 2 solution.

        ```python3
        >>> f = open("../tests/2024/day02.txt")
        >>> Solution.part_2(f.read())
        4
        >>> f2 = open("../tests/2024/day022.txt")
        >>> Solution.part_2(f2.read())
        28
        >>> f.close(); f2.close()

        ```

        Returns
        -------
        The result.

        """
        lnums = [[int(n) for n in line.split()] for line in data.splitlines()]
        invalids = [(lst, _calc_difs(lst)) for lst in lnums if not _validate(lst)]
        checks = [
            (
                nums,
                [MIN_DIF <= abs(d) <= MAX_DIF for d in difs],
                [i > 0 for i in difs],
                [i < 0 for i in difs],
            )
            for nums, difs in invalids
        ]
        checks_merged = [
            (nums, mag, pos if sum(pos) > sum(neg) else neg)
            for nums, mag, pos, neg in checks
        ]
        wrong_indices = [
            (nums, next(i for i in range(len(nums) - 1) if not (mag[i] and sign[i])))
            for nums, mag, sign in checks_merged
        ]

        variations = [
            (lst, _remove_item(lst, idx), _remove_item(lst, idx + 1))
            for lst, idx in wrong_indices
        ]

        validated = [(lst, _validate(a), _validate(b)) for lst, a, b in variations]
        rem = [not frst and not scnd for _, frst, scnd in validated]

        return len(lnums) - sum(rem)


def _calc_difs(nums: list[int]) -> list[int]:
    return [nums[i] - nums[i + 1] for i in range(len(nums) - 1)]


def _validate(nums: list[int]) -> bool:
    difc = _calc_difs(nums)
    return all(MIN_DIF <= abs(d) <= MAX_DIF for d in difc) and (
        all(d < 0 for d in difc) or all(d > 0 for d in difc)
    )


def _remove_item(nums: list[int], idx: int) -> list[int]:
    new = nums.copy()
    idx_checked = min(len(nums) - 1, idx)
    _ = new.pop(idx_checked)
    return new
