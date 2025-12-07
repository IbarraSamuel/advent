from algorithm import parallelize
from memory import pack_bits, bitcast
from bit import prev_power_of_two
from math import log2

from advent_utils import AdventSolution


fn calc_simd(
    f: SIMD[DType.int8, 8]
) -> Tuple[SIMD[DType.bool, 8], SIMD[DType.bool, 8]]:
    """This could be improved to precisely show the place where the problem is.
    """
    l = f.shift_left[1]()
    zero_msk = l.eq(0)
    diff = l - f
    is_positive_in_bounds = zero_msk | ~((diff.lt(1)) | (diff.gt(3)))
    is_negative_in_bounds = zero_msk | ~((diff.gt(-1)) | (diff.lt(-3)))
    return is_positive_in_bounds, is_negative_in_bounds


fn slice_to_num(slice: StringSlice) -> Int:
    alias zeroord = ord("0")
    var bts = slice.as_bytes()
    if len(bts) == 1:
        return Int(bts[0] - zeroord)
    return Int(bts[0]) * 10 + Int(bts[1]) - 11 * zeroord


struct Solution(AdventSolution):
    alias T = Int32
    alias IdxSIMD = SIMD[DType.int8, 8](0, 1, 2, 3, 4, 5, 6, 7)
    alias ZeroSIMD = SIMD[DType.int8, 8](0)

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
        """Part 1 test.

        ```mojo
        from advent_utils import test
        from days.day02 import Solution

        test[Solution, file="tests/2024/day02.txt", part=1, expected=2]()

        ```"""
        result = 0
        ref lines = data.splitlines()
        for lidx in range(len(lines)):
            ref line = lines.unsafe_get(lidx)
            ref nums = line.split()
            var n1 = slice_to_num(nums.unsafe_get(0))
            var last = slice_to_num(nums.unsafe_get(1))
            var sign = (last - n1) > 0
            var diff = last - n1
            if diff < -3 or diff > 3 or diff == 0:
                continue
            for ni in range(2, len(nums)):  # go one in future
                var current = slice_to_num(nums.unsafe_get(ni))
                diff = current - last
                if diff == 0 or diff < -3 or diff > 3 or (diff > 0) ^ sign:
                    break
                last = current
            else:
                result += 1
        return result

    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
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
            ref nums = lines.unsafe_get(idx).split()
            f = SIMD[DType.int8, 8](0)
            try:
                for i in range(len(nums)):
                    f[i] = Int(nums[i])
            except:
                pass
            pos, neg = calc_simd(f)
            if all(pos) or all(neg):
                results[idx] = 1
                continue

            s_pos = Int(log2(Float64(prev_power_of_two(pack_bits(~pos)))))
            s_neg = Int(log2(Float64(prev_power_of_two(pack_bits(~neg)))))

            # TODO: Make it nicer, now it's kind of good but brute forced on two options.

            # calc for positive
            fpos_msk = SIMD[DType.bool, f.size](fill=False)
            for i in range(s_pos, f.size):
                fpos_msk[i] = True

            fpos = fpos_msk.select(f.shift_left[1](), f)
            fpos2 = fpos
            fpos2[s_pos] = f[s_pos]
            p, n = calc_simd(fpos)
            if all(p) or all(n):
                results[idx] = 1
                continue
            p, n = calc_simd(fpos2)
            if all(p) or all(n):
                results[idx] = 1
                continue

            # Calc for negative
            fneg_msk = SIMD[DType.bool, f.size](fill=False)
            for i in range(s_neg, f.size):
                fneg_msk[i] = True

            fneg = fneg_msk.select(f.shift_left[1](), f)
            fneg2 = fneg
            fneg2[s_neg] = f[s_neg]
            p, n = calc_simd(fneg)
            if all(p) or all(n):
                results[idx] = 1
                continue
            p, n = calc_simd(fneg2)
            if all(p) or all(n):
                results[idx] = 1
                continue

        return results.reduce_add()
