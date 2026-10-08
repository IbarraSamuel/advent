from std.memory import pack_bits, bitcast
from std.bit import prev_power_of_two
from std.math import log2

from advent_utils import AdventSolution


def calc_simd(
    f: SIMD[DType.int8, 8]
) -> Tuple[SIMD[DType.bool, 8], SIMD[DType.bool, 8]]:
    """This could be improved to precisely show the place where the problem is.
    """
    var l = f.shift_left[1]()
    var zero_msk = l.eq(0)
    var diff = l - f
    var is_positive_in_bounds = zero_msk | ~((diff.lt(1)) | (diff.gt(3)))
    var is_negative_in_bounds = zero_msk | ~((diff.gt(-1)) | (diff.lt(-3)))
    return is_positive_in_bounds, is_negative_in_bounds


def slice_to_num(slice: StringSlice) -> Int:
    comptime zeroord = Byte(ord("0"))
    var bts = slice.as_bytes()
    if len(bts) == 1:
        return Int(bts[0] - zeroord)
    return Int(bts[0]) * 10 + Int(bts[1]) - 11 * Int(zeroord)


struct Solution(AdventSolution):
    comptime T = Int
    comptime IdxSIMD = SIMD[DType.int8, 8](0, 1, 2, 3, 4, 5, 6, 7)
    comptime ZeroSIMD = SIMD[DType.int8, 8](0)

    @staticmethod
    def part_1(data: StringSlice) -> Self.T:
        var result = 0
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
    def part_2(data: StringSlice) -> Self.T:
        var lines = data.splitlines()
        var results = SIMD[DType.int32, 1024](0)

        for idx in range(len(lines)):
            ref nums = lines.unsafe_get(idx).split()
            var f = SIMD[DType.int8, 8](0)
            try:
                for i in range(len(nums)):
                    f[i] = Int8(Int(nums[i]))
            except:
                pass
            var pos, neg = calc_simd(f)
            if all(pos) or all(neg):
                results[idx] = 1
                continue

            var s_pos = Int(log2(Float64(prev_power_of_two(pack_bits(~pos)))))
            var s_neg = Int(log2(Float64(prev_power_of_two(pack_bits(~neg)))))

            # TODO: Make it nicer, now it's kind of good but brute forced on two options.

            # calc for positive
            var fpos_msk = SIMD[DType.bool, 8](fill=False)
            for i in range(s_pos, 8):
                fpos_msk[i] = True

            var fpos = fpos_msk.select(f.shift_left[1](), f)
            var fpos2 = fpos
            fpos2[s_pos] = f[s_pos]
            var p_pos, n_pos = calc_simd(fpos)
            if all(p_pos) or all(n_pos):
                results[idx] = 1
                continue
            var p_pos2, n_pos2 = calc_simd(fpos2)
            if all(p_pos2) or all(n_pos2):
                results[idx] = 1
                continue

            # Calc for negative
            var fneg_msk = SIMD[DType.bool, 8](fill=False)
            for i in range(s_neg, 8):
                fneg_msk[i] = True

            var fneg = fneg_msk.select(f.shift_left[1](), f)
            var fneg2 = fneg
            fneg2[s_neg] = f[s_neg]
            var p_neg, n_neg = calc_simd(fneg)
            if all(p_neg) or all(n_neg):
                results[idx] = 1
                continue
            var p_neg2, n_neg2 = calc_simd(fneg2)
            if all(p_neg2) or all(n_neg2):
                results[idx] = 1
                continue

        return Int(results.reduce_add())
