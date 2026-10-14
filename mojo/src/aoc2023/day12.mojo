from std.collections import Dict
import std.os as os

from advent_utils import AdventSolution


def count(
    cfg: StringSlice,
    nums: Span[mut=False, Int, _],
    mut cache: Dict[String, Int],
) -> Int:
    if (not cfg and not nums) or (not nums and "#" not in cfg):
        return 1

    if (not cfg and nums) or (not nums and "#" in cfg):
        return 0

    var k = String(cfg)
    k.write("|")
    for num in nums:
        k.write(String(num), ",")
    var vl = cache.get(k)
    if vl:
        return vl.value()

    var result = 0

    if cfg[byte=:1] in ".?":
        result += count(cfg[byte=1:], nums, cache)

    if cfg[byte=:1] in "#?" and (
        nums[0] <= cfg.byte_length()
        and "." not in cfg[byte = : nums[0]]
        and (
            nums[0] == cfg.byte_length()
            or cfg[byte=nums[0]] != StringSlice("#")
        )
    ):
        var next_cfg_start = min(nums[0] + 1, cfg.byte_length())
        result += count(cfg[byte=next_cfg_start:], nums[1:], cache)

    cache[k^] = result
    return result


struct Solution(AdventSolution):
    """Solution for day 12."""

    @staticmethod
    def part_1(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = Int32(0)
        for idx in range(len(lines)):
            var splitted = lines[idx].split()
            var cfg, nums_chr = splitted[0], splitted[1]
            var nums = List[Int]()
            try:
                var splitted_nums = nums_chr.split(",")
                for num in splitted_nums:
                    nums.append(Int(num))
            except:
                os.abort("This should never happen")

            var cache = Dict[String, Int]()
            total += Int32(count(cfg, nums, cache))

        return total

    @staticmethod
    def part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        var total = Int32(0)
        for idx in range(len(lines)):
            var splitted = lines[idx].split()
            var cfg = String(splitted[0])
            var nums_chr = splitted[1]
            var nums = List[Int]()
            try:
                var splitted_nums = nums_chr.split(",")
                for num in splitted_nums:
                    nums.append(Int(num))
            except:
                os.abort("This should never happen")

            cfg = String((("?" + cfg) * 5)[byte=1:])
            nums *= 5
            var cache = Dict[String, Int]()
            total += Int32(count(cfg, nums, cache))

        return total
