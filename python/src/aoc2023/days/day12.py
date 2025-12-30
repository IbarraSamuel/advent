"""Day 12 results."""
from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Sequence


def count(
    cfg: str, nums: tuple[int, ...], cache: dict[tuple[str, tuple[int, ...]], int],
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
    return result


class Solution:
    """Solution for day 12."""

    @staticmethod
    def part_1(lines: Sequence[str]) -> int:
        total = 0
        for line in lines:
            cfg, nums = line.split()
            nums = tuple(int(n) for n in nums.split(","))
            total += count(cfg, nums, {})
        return total

    @staticmethod
    def part_2(lines: Sequence[str]) -> int:
        total = 0
        for line in lines:
            cfg, nums = line.split()
            nums = tuple(int(n) for n in nums.split(","))
            cfg = "?".join([cfg] * 5)
            nums *= 5
            result = count(cfg, nums, {})
            total += result
        return total
