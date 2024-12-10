from collections import Optional
from algorithm import parallelize
from memory import pack_bits, bitcast
from bit import bit_floor
from math import log2


fn to_int(v: String) -> Int:
    try:
        return int(v)
    except:
        return 0


fn calc_simd(
    f: SIMD[DType.int8, 8]
) -> (SIMD[DType.bool, 8], SIMD[DType.bool, 8]):
    l = f.shift_left[1]()
    zero_msk = l == 0
    diff = l - f
    is_positive_in_bounds = zero_msk | ~((diff < 1) | (diff > 3))
    is_negative_in_bounds = zero_msk | ~((diff > -1) | (diff < -3))
    return is_positive_in_bounds, is_negative_in_bounds


struct Solution:
    alias T = DType.int32
    alias IdxSIMD = SIMD[DType.int8, 8](0, 1, 2, 3, 4, 5, 6, 7)
    alias ZeroSIMD = SIMD[DType.int8, 8](0)

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        """Part 1 test.

        ```mojo
        from advent_utils import test
        from days.day02 import Solution

        test[Solution, file="tests/2024/day02.txt", part=1, expected=2]()

        ```"""
        lines = data.splitlines()
        results = SIMD[DType.int32, 1024](0)

        @parameter
        fn calc_line(idx: Int):
            nums = lines[idx].split()
            f = SIMD[DType.int8, 8](0)
            for i in range(len(nums)):
                f[i] = to_int(nums[i])

            pos, neg = calc_simd(f)
            results[idx] = int(all(pos) or all(neg))

        parallelize[calc_line](len(lines))

        return results.reduce_add()

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        """Part 2 test.

        ```mojo
        from advent_utils import test
        from days.day02 import Solution

        test[Solution, file="tests/2024/day02.txt", part=2, expected=4]()
        test[Solution, file="tests/2024/day022.txt", part=2, expected=1]()
        ```"""
        lines = data.splitlines()
        results = SIMD[DType.int32, 1024](0)

        for idx in range(len(lines)):
            nums = lines[idx].split()
            f = SIMD[DType.int8, 8](0)
            for i in range(len(nums)):
                f[i] = to_int(nums[i])

            pos, neg = calc_simd(f)
            if all(pos) or all(neg):
                results[idx] = 1
                continue

            # hey, validate
            # If ~pos has less than 3 ones, or ~neg, we can calculate. Else just skip it.
            # negative should be ~pos.reduce_add() > 2 or ~neg.reduce_add() > 2
            # Why two? In the case of 3, 20, 4 >> we could still be valid if we remove 20
            # This may not be needed, but could improve performance
            if ~pos.reduce_add() > 2 or ~neg.reduce_add() > 2:
                continue

            # Now, we can one thing >> get the one closest to the right, and simply remove the value and calc again.
            # Why the closest to the right? It handles both cases of 1 bad or 2 bads.
            # the process is:
            # 1. pack the 1 and 0 to a integer number.
            # 2. do bit floor to get the number closest to the right
            # 3. log2 to get the index (need cast to float before)

            s_pos = log2(float(bit_floor(pack_bits(pos)))).cast[DType.uint8]()
            s_neg = log2(float(bit_floor(pack_bits(pos)))).cast[DType.uint8]()
            print(s_pos)
            print(s_neg)
            fpos = bitcast[DType.bool, 8](s_pos - 1).select(
                f, f.shift_left[1]()
            )
            fneg = bitcast[DType.bool, 8](s_neg - 1).select(
                f, f.shift_left[1]()
            )

            pos, neg = calc_simd(fpos)
            if all(pos) or all(neg):
                results[idx] = 1
                continue

            pos, neg = calc_simd(fneg)
            results[idx] = int(all(pos) or all(neg))

        return results.reduce_add()


fn is_invalid(asc: Bool, pair: (Int, Int)) -> Bool:
    f, l = pair
    return (asc != (f < l)) or abs(f - l) > 3 or f == l


fn should_retry_first(asc: Bool, i: Int, nums: List[String]) raises -> Bool:
    print(
        "nums",
        nums[i],
        nums[i + 1],
        "failed but trying now to compare with",
        nums[i + 2],
        "in order asc:",
        asc,
    )
    f, n = int(nums[i]), int(nums[i + 2])
    ignore_middle = f, n
    return not is_invalid(asc, ignore_middle)
