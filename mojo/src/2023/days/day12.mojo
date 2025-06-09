from advent_utils import SIMDResult, ListSolution
from algorithm import parallelize
from collections import Dict
import os


@value
struct CacheKey(KeyElement):
    var cfg: String
    var nums: List[Int]

    fn __hash__(self) -> UInt:
        return self.cfg.__hash__()

    fn __eq__(self, other: Self) -> Bool:
        return self.cfg == other.cfg and self.nums == other.nums

    fn __ne__(self, other: Self) -> Bool:
        return not self == other

    fn __repr__(self) -> String:
        try:
            return StringSlice("(cfg: {}, nums: {})").format(
                self.cfg, self.nums.__str__()
            )
        except:
            return "repre raises"


fn count(cfg: String, nums: List[Int], mut cache: Dict[CacheKey, Int]) -> Int:
    if (not cfg and not nums) or (not nums and "#" not in cfg):
        return 1

    if (not cfg and nums) or (not nums and "#" in cfg):
        return 0

    k = CacheKey(cfg, nums)
    vl = cache.get(k)
    if vl:
        return vl.value()

    result = 0

    if cfg[0] in ".?":
        result += count(cfg[1:], nums, cache)

    if cfg[0] in "#?" and (
        nums[0] <= len(cfg)
        and "." not in cfg[: nums[0]]
        and (nums[0] == len(cfg) or cfg[nums[0]] != "#")
    ):
        result += count(cfg[nums[0] + 1 :], nums[1:], cache)

    cache[k] = result
    return result


struct Solution(ListSolution):
    """Solution for day 12."""

    alias dtype = DType.uint64

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        total = SIMD[DType.uint32, 1024](0)

        @parameter
        fn calc_line(idx: Int):
            # for idx in range(len(lines)):
            splitted = lines[idx].split()
            cfg, nums_chr = splitted[0], splitted[1]
            nums = List[Int]()
            try:
                splitted_nums = nums_chr.split(",")
                for num in splitted_nums:
                    nums.append(Int(num))
            except:
                os.abort("This should never happen")
            cache = Dict[CacheKey, Int]()
            total[idx] = count(cfg, nums, cache)
            # total[idx] = count(cfg, nums)

        parallelize[calc_line](len(lines))
        return total.reduce_add().cast[DType.uint64]()

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        total = SIMD[DType.uint64, 1024](0)

        @parameter
        fn calc_line(idx: Int):
            splitted = lines[idx].split()
            cfg, nums_chr = splitted[0], splitted[1]
            nums = List[Int]()
            try:
                splitted_nums = nums_chr.split(",")
                for num in splitted_nums:
                    nums.append(Int(num))
            except:
                os.abort("This should never happen")
            cfg = (("?" + cfg) * 5)[1:]
            nums *= 5
            cache = Dict[CacheKey, Int]()
            total[idx] = count(cfg, nums, cache)
            # total[idx] = count(cfg, nums)

        parallelize[calc_line](len(lines))
        return total.reduce_add()
