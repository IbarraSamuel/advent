from std.math import sqrt, floor, ceil
from advent_utils import AdventSolution


@always_inline
def quadratic_solution(
    a: Float64, b: Float64, c: Float64
) -> Tuple[Float64, Float64]:
    var cns = -b / (2 * a)
    var v = sqrt(b**2 - 4.0 * a * c) / (2 * a)
    return cns - v, cns + v


@always_inline
def races_winning(duration: Float64, record: Float64) -> Int:
    var a, b, c = 1.0, -duration, record
    var lower, upper = quadratic_solution(a, b, c)
    lower, upper = floor(lower + 1), ceil(upper - 1)
    var lower_int, upper_int = Int(lower), Int(upper)
    return upper_int - lower_int + 1


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    def part_1(data: StringSlice) -> Int:
        var input = data.splitlines()
        var total = 1
        for r_idx in range(len(input[0].split()) - 1):
            var duration = input[0].split()[r_idx + 1]
            var record = input[1].split()[r_idx + 1]
            try:
                var duration_int = Float64(duration)
                var record_int = Float64(record)
                total *= races_winning(duration_int, record_int)
            except:
                pass

        return total

    @staticmethod
    def part_2(data: StringSlice) -> Int:
        var input = data.splitlines()
        var duration = StaticString("").join(input[0].split()[1:])
        var record = StaticString("").join(input[1].split()[1:])
        try:
            var duration_int = Float64(duration)
            var record_int = Float64(record)
            return races_winning(duration_int, record_int)
        except:
            return 0
