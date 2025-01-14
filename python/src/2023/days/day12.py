"""Day 12 results."""

from collections.abc import Sequence
from typing import override

from advent_utils import AdventSolution


def count(
    cfg: str, nums: tuple[int, ...], cache: dict[tuple[str, tuple[int, ...]], int]
) -> int:
    """
    Define all possible combos.

    Returns
    -------
    the count for this specifig cfg.

    """
    if (not cfg and not nums) or (not nums and "#" not in cfg):
        return 1

    if (not cfg and nums) or (not nums and "#" in cfg):
        return 0

    key = (cfg, nums)
    if key in cache:
        print(cfg, end="--")
        print(list(nums), end="--cached\n")
        return cache[key]

    result = 0

    if cfg[0] != "#":
        result += count(cfg[1:], nums, cache)

    if cfg[0] != "." and (
        nums[0] <= len(cfg)
        and "." not in cfg[: nums[0]]
        and (nums[0] == len(cfg) or cfg[nums[0]] != "#")
    ):
        result += count(cfg[nums[0] + 1 :], nums[1:], cache)

    cache[key] = result
    print(cfg, end="--")
    print(list(nums))
    return result


class Solution(AdventSolution):
    """Solution for day 12."""

    @override
    @staticmethod
    def part_1(lines: Sequence[str]) -> int:
        total = 0
        for line in lines:
            cfg, nums = line.split()
            nums = tuple(int(n) for n in nums.split(","))
            total += count(cfg, nums, {})
        return total

    @override
    @staticmethod
    def part_2(lines: Sequence[str]) -> int:
        total = 0
        for line in lines:
            cfg, nums = line.split()
            nums = tuple(int(n) for n in nums.split(","))
            cfg = "?".join([cfg] * 5)
            nums *= 5
            result = count(cfg, nums, {})
            print(result)
            total += result
        return total
