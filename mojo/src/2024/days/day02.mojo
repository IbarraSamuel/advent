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
    """This could be improved to precisely show the place where the problem is.
    """
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
        test[Solution, file="tests/2024/day022.txt", part=2, expected=28]()
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
                print(idx, end=" ")
                continue

            s_pos = int(log2(float(bit_floor(pack_bits(~pos)))))
            s_neg = int(log2(float(bit_floor(pack_bits(~neg)))))

            # TODO: Make it nicer, now it's kind of good but brute forced on two options.

            # calc for positive
            fpos_msk = SIMD[DType.bool, f.size](False)
            for i in range(s_pos, f.size):
                fpos_msk[i] = True

            fpos = fpos_msk.select(f.shift_left[1](), f)
            fpos2 = fpos
            fpos2[s_pos] = f[s_pos]
            p, n = calc_simd(fpos)
            if all(p) or all(n):
                results[idx] = 1
                print(idx, end=" ")
                continue
            p, n = calc_simd(fpos2)
            if all(p) or all(n):
                results[idx] = 1
                print(idx, end=" ")
                continue

            # Calc for negative
            fneg_msk = SIMD[DType.bool, f.size](False)
            for i in range(s_neg, f.size):
                fneg_msk[i] = True

            fneg = fneg_msk.select(f.shift_left[1](), f)
            fneg2 = fneg
            fneg2[s_neg] = f[s_neg]
            p, n = calc_simd(fneg)
            if all(p) or all(n):
                results[idx] = 1
                print(idx, end=" ")
                continue
            p, n = calc_simd(fneg2)
            if all(p) or all(n):
                results[idx] = 1
                print(idx, end=" ")
                continue

        print("")
        return results.reduce_add()


# fn is_invalid(asc: Bool, pair: (Int, Int)) -> Bool:
#     f, l = pair
#     return (asc != (f < l)) or abs(f - l) > 3 or f == l


# fn should_retry_first(asc: Bool, i: Int, nums: List[String]) raises -> Bool:
#     print(
#         "nums",
#         nums[i],
#         nums[i + 1],
#         "failed but trying now to compare with",
#         nums[i + 2],
#         "in order asc:",
#         asc,
#     )
#     f, n = int(nums[i]), int(nums[i + 2])
#     ignore_middle = f, n
#     return not is_invalid(asc, ignore_middle)
