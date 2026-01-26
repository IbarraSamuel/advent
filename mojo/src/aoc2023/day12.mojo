from advent_utils import AdventSolution
from algorithm import parallelize
from collections import Dict
import os

from hashlib.hasher import Hasher


@fieldwise_init
struct CacheKey[o: ImmutOrigin](KeyElement):
    var cfg: String
    var nums: Span[Int, Self.o]

    fn __hash__[H: Hasher](self, mut hasher: H):
        hasher.update(self.cfg)


fn count(
    cfg: StringSlice,
    nums: Span[Int],
    mut cache: Dict[CacheKey[nums.origin], Int],
) -> Int:
    if (not cfg and not nums) or (not nums and "#" not in cfg):
        return 1

    if (not cfg and nums) or (not nums and "#" in cfg):
        return 0

    k = CacheKey(String(cfg), nums.copy())
    vl = cache.get(k)
    if vl:
        return vl.value()

    result = 0

    if cfg[:1] in ".?":
        result += count(cfg[1:], nums, cache)

    if cfg[:1] in "#?" and (
        nums[0] <= len(cfg)
        and "." not in cfg[: nums[0]]
        and (nums[0] == len(cfg) or cfg[byte = nums[0]] != "#")
    ):
        result += count(cfg[nums[0] + 1 :], nums[1:], cache)

    cache[k^] = result
    return result


struct Solution(AdventSolution):
    """Solution for day 12."""

    @staticmethod
    fn part_1(data: StringSlice) -> Int32:
        var lines = data.splitlines()
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

            cache = Dict[CacheKey[ImmutOrigin(origin_of(nums))], Int]()
            total[idx] = count(cfg, nums^, cache)
            # total[idx] = count(cfg, nums)

        parallelize[calc_line](len(lines))
        return total.reduce_add().cast[DType.int32]()

    @staticmethod
    fn part_2(data: StringSlice) -> Int32:
        var lines = data.splitlines()
        total = SIMD[DType.uint64, 1024](0)

        @parameter
        fn calc_line(idx: Int):
            splitted = lines[idx].split()
            cfg = String(splitted[0])
            nums_chr = splitted[1]
            nums = List[Int]()
            try:
                splitted_nums = nums_chr.split(",")
                for num in splitted_nums:
                    nums.append(Int(num))
            except:
                os.abort("This should never happen")

            cfg = String((("?" + cfg) * 5)[1:])
            nums *= 5
            # span = nums[:]
            cache = Dict[CacheKey[ImmutOrigin(origin_of(nums))], Int]()
            total[idx] = count(cfg, nums^, cache)
            # total[idx] = count(cfg, nums)

        parallelize[calc_line](len(lines))
        return total.reduce_add().cast[DType.int32]()
