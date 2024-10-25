from advent_utils import AdventSolution, SIMDResult
from algorithm import parallelize
from collections import Dict, InlineList
import os


@value
struct CacheKey(KeyElement):
    var cfg: String
    var nums: List[Int]

    fn __hash__(self) -> UInt:
        return (self.cfg + self.nums.__str__()).__hash__()

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

    k = CacheKey(cfg, nums)
    vl = cache.find(k)
    if vl:
        return vl.value()

    result = 0

    if cfg[0] != "#":
        result += count(cfg[1:], nums, cache)

    if cfg[0] != "." and (
        nums[0] <= len(cfg)
        and "." not in cfg[: nums[0]]
        and (nums[0] == len(cfg) or cfg[nums[0]] != "#")
    ):
        result += count(cfg[nums[0] + 1 :], nums[1:], cache)

    cache[k] = result
    return result


struct Solution(AdventSolution):
    """Solution for day 12."""

    alias dtype = DType.uint32

    @staticmethod
    fn part_1(lines: List[String]) -> UInt32:
        total = SIMDResult(0)

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
                os.abort("This shoudl never happen")
            cache = Dict[CacheKey, Int]()
            total[idx] = count(cfg, nums, cache)

        parallelize[calc_line](lines.size)
        return total.reduce_add()

    @staticmethod
    fn part_2(lines: List[String]) -> UInt32:
        total = SIMDResult(0)

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
                os.abort("This shoudl never happen")
            cfg = (("?" + cfg) * 5)[1:]
            nums *= 5
            cache = Dict[CacheKey, Int]()
            total[idx] = count(cfg, nums, cache)

        parallelize[calc_line](lines.size)
        return total.reduce_add()


# fn sig_and_pattern(
#     line: String,
# ) -> (String, String):
#     space_idx = line.find(" ")
#     signature = line[:space_idx].strip(".")
#     r_groups = line[space_idx + 1 :]

#     pat = String()
#     g_idx = 0

#     while g_idx < len(r_groups):
#         if r_groups[g_idx] == ",":
#             pat.write(".")
#             g_idx += 1
#             continue

#         n_idx = r_groups.find(",", g_idx)
#         if n_idx == -1:
#             n_idx = len(r_groups)

#         try:
#             n = int(r_groups[g_idx:n_idx])
#         except:
#             pass

#         g_idx = n_idx
#         pat.write(String("#") * n)
#     return signature, pat


# fn calc_path_val(
#     sig: String, pat: String, inout cache: Dict[String, Int]
# ) -> Int:
#     print("\n", sig, pat, end=" -- ")
#     cache_key = sig + pat

#     if cache_key in cache:
#         print("cached!", end="")
#         return cache.get(cache_key).value()

#     if sig == pat:
#         print("Exactly the same -- +1", end="")
#         cache[cache_key] = 3
#         return 1

#     if len(sig) < len(pat):
#         print("not enought sig", end="")
#         cache[cache_key] = 0
#         return 0

#     if len(pat) == 0:
#         print("Pattern finished and signature still alive", end="")
#         cache[cache_key] = 0
#         return 0

#     s, p = sig[0], pat[0]

#     if s == "#":
#         if p != s:
#             print("Mismatch sig vs pat", end="")
#             cache[cache_key] = 0
#             return 0
#         res = calc_path_val(sig[1:], pat[1:], cache)
#         cache[cache_key] = res
#         return res
#     if s == ".":
#         if p == s:
#             res = calc_path_val(sig[1:], pat[1:], cache)
#             cache[cache_key] = res
#             return res
#         res = calc_path_val(sig[1:], pat, cache)
#         cache[cache_key] = res
#         return res
#     if s == "?":
#         hash = calc_path_val("#" + sig[1:], pat, cache)
#         dot = calc_path_val("." + sig[1:], pat, cache)
#         cache[cache_key] = dot + hash
#         return hash + dot

#     os.abort("Unreachable")
#     return 0


# fn calc_line(line: String) -> Int32:
#     print("--------------------")
#     print(line)
#     sig, pat = sig_and_pattern(line)
#     cache = Dict[String, Int]()
#     res = calc_path_val(sig, pat, cache)
#     print()
#     print(res)
#     return res


# fn calc_line_2(line: String) -> Int32:
#     print("--------------------")
#     sig, pat = sig_and_pattern(line)
#     sig = "?".join(List(sig, sig, sig, sig, sig))
#     pat = ".".join(List(pat, pat, pat, pat, pat))
#     cache = Dict[String, Int]()
#     res = calc_path_val(sig, pat, cache)
#     print()
#     return res


# struct Solution(AdventSolution):
#     alias dtype = DType.int32

#     @staticmethod
#     fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
#         r = SIMD[DType.int32, 1024](0)

#         # @parameter
#         # fn calc(idx: Int):
#         for idx in range(lines.size):
#             r[idx] = calc_line(lines.unsafe_get(idx))

#         # parallelize[calc](lines.size)
#         return r.reduce_add()

#     @staticmethod
#     fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
#         r = SIMD[DType.int32, 1024](0)

#         # @parameter
#         # fn calc(idx: Int):
#         for idx in range(lines.size):
#             r[idx] = calc_line_2(lines.unsafe_get(idx))

#         # parallelize[calc](lines.size)
#         return r.reduce_add()
