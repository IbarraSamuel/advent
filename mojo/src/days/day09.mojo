from advent_utils import AdventSolution, AdventResult
from utils import StaticIntTuple

alias Size = 32
alias Line = SIMD[DType.int64, Size]
alias Mask = SIMD[DType.bool, Size]


fn calc_prev_and_next(owned value: Line, owned last: Int) -> (Int, Int):
    all_results = List[StaticIntTuple[2]](capacity=Size)
    all_results.append((int(value[0]), int(value[last - 1])))
    while not (value == 0).reduce_and():
        last -= 1
        value = value.shift_left[1]() - value
        value[last] = 0
        all_results.append((int(value[0]), int(value[last - 1])))

    frst, lst = 0, 0
    for idx in range(all_results.size):
        frst = all_results[all_results.size - idx - 1][0] - frst
        lst += all_results[idx][1]

    return frst, lst


fn create_line(v: String) -> (Line, Int):
    values = v.split()
    line = Line(0)
    for i in range(len(values)):
        try:
            line[i] = int(values[i])
        except:
            pass

    return (line, values.size)


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        tot = 0
        for str_line in lines:
            line, last = create_line(str_line[])
            _, l = calc_prev_and_next(line, last)
            tot += l
        return tot

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        tot = 0
        for str_line in lines:
            line, last = create_line(str_line[])
            f, _ = calc_prev_and_next(line, last)
            tot += f
        return tot
