# from collections import Dict
# from collections.string import StringSlice
# from advent_utils import AdventSolution, SIMDResult, map
# import os
# from algorithm.functional import parallelize


# fn should_instert_it(
#     footprint: String,
#     group_size: Int,
#     groups_len: Int,
#     current_position: Int,
#     group_idx: Int,
# ) -> Bool:
#     i = current_position
#     contains_hash = False

#     while i < len(footprint):
#         if footprint[i] == "." and i < current_position + group_size:
#             return False
#         if footprint[i] == "#" and i >= current_position + group_size:
#             contains_hash = True
#             break
#         i += 1

#     return current_position + group_size - 1 < len(footprint) and (
#         (group_idx == groups_len - 1 and not contains_hash)
#         or (
#             group_idx < groups_len - 1
#             and current_position + group_size < len(footprint)
#             and footprint[current_position + group_size] != "#"
#         )
#     )


# fn count(footprint: String, groups: List[Int]) -> Int:
#     groups_len = len(groups)
#     acc = List((0, 1))
#     rem_group_size = 0

#     for g in groups:
#         rem_group_size += g[]

#     for group_idx in range(len(groups)):
#         group_size = groups[group_idx]

#         new_positions = List[(Int, Int)](capacity=30)
#         for a in acc:
#             k, v = a[]
#             for current_position in range(
#                 k,
#                 len(footprint)
#                 - rem_group_size
#                 + group_size
#                 + groups_len
#                 - group_idx
#                 - 1,
#             ):
#                 if should_instert_it(
#                     footprint,
#                     group_size,
#                     groups_len,
#                     current_position,
#                     group_idx,
#                 ):
#                     for tp in new_positions:
#                         pos, nxt = tp[]
#                         if pos == current_position + group_size + 1:
#                             tp[] = pos, nxt + v
#                             break
#                     else:
#                         new_positions.append(
#                             (current_position + group_size + 1, v)
#                         )

#                 if footprint[current_position : current_position + 1] == "#":
#                     break

#         acc, rem_group_size = new_positions, rem_group_size - group_size

#     tot = 0
#     for a in acc:
#         tot += a[][1]

#     return tot


# Rust impl

from advent_utils import SIMDResult
from algorithm import parallelize
from collections import Dict, InlineList
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
            return "(cfg: {}, nums: {})".format(self.cfg, self.nums.__str__())
        except:
            return "repre raises"


fn count(cfg: String, nums: List[Int], inout cache: Dict[CacheKey, Int]) -> Int:
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


struct Solution:
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
                    nums.append(int(num[]))
            except:
                os.abort("This should never happen")
            cache = Dict[CacheKey, Int]()
            total[idx] = count(cfg, nums, cache)
            # total[idx] = count(cfg, nums)

        parallelize[calc_line](lines.size)
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
                    nums.append(int(num[]))
            except:
                os.abort("This should never happen")
            cfg = (("?" + cfg) * 5)[1:]
            nums *= 5
            cache = Dict[CacheKey, Int]()
            total[idx] = count(cfg, nums, cache)
            # total[idx] = count(cfg, nums)

        parallelize[calc_line](lines.size)
        return total.reduce_add()
