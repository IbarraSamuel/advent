from algorithm import parallelize
import os
from builtin.file import FileHandle
from collections import Optional
from advent_utils import ListSolution

alias Size = 32
alias Line = SIMD[DType.int64, Size]


fn calc_prev_and_next(var value: Line, last: Int) -> (Int64, Int64):
    idx, frst, lst = 0, Int64(0), Int64(0)
    while not (value == 0).reduce_and():
        frst = value[0] - frst
        lst += value[last - 1 - idx]
        value = value.shift_left[1]() - value
        value[last - 1 - idx] = 0
        idx += 1

    if not idx % 2:
        frst = -frst

    return frst, lst


fn create_line(v: String) -> (Line, Int):
    values = v.split()
    line = Line(0)

    try:

        @parameter
        for i in range(21):
            if i >= len(values):
                break
            line[i] = Int(values[i])
    except:
        os.abort("bad bad on create line")
        pass

    return (line, len(values))


struct Solution(ListSolution):
    alias dtype = DType.int64

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        tot = SIMD[DType.int64, 256](0)

        @parameter
        fn calc(idx: Int):
            line, last = create_line(lines[idx])
            _, l = calc_prev_and_next(line, last)
            tot[idx] = l

        parallelize[calc](len(lines))
        return tot.reduce_add()

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        tot = SIMD[DType.int64, 256](0)

        @parameter
        fn calc(idx: Int):
            line, last = create_line(lines[idx])
            f, _ = calc_prev_and_next(line, last)
            tot[idx] = f

        parallelize[calc](len(lines))
        return tot.reduce_add()
