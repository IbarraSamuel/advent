from collections import Optional


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
        results = 0

        for idx in range(len(lines)):
            nums = lines[idx].split()
            asc = to_int(nums[0]) < to_int(nums[1])
            for i in range(len(nums) - 1):
                f, l = to_int(nums[i]), to_int(nums[i + 1])
                if (asc != (f < l)) or abs(f - l) > 3 or f == l:
                    break
            else:
                results += 1

        return results

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

            # Hey, validate
            print("failed, exploring")
            print((~pos))
            print((~neg))
            pos_one_bad = (
                (~pos).select(Self.IdxSIMD, Self.ZeroSIMD).reduce_min()
            )
            if pos_one_bad == 7:
                f = f.shift_right[1]()
            if pos_one_bad == 0:
                f = f.shift_left[1]()

            pos, neg = calc_simd(f)
            if all(pos) or all(neg):
                results[idx] = 1
                continue

            @parameter
            for ci in range(1, 7):
                if ci == int(pos_one_bad):
                    f = f.insert[offset=ci](f)
                    break

            pos, neg = calc_simd(f)
            if all(pos) or all(neg):
                continue

            # Negative missing

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
