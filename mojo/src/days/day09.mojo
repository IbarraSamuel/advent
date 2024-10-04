from advent_utils import (
    TensorSolution,
    FileTensor,
    GenericAdventSolution,
    TestMovableResult,
)
from utils import StaticIntTuple
from algorithm import parallelize
import os

alias Size = 32
alias Line = SIMD[DType.int64, Size]
alias Mask = SIMD[DType.bool, Size]
alias EMPTY_RES = SIMD[DType.int64, Size * 2](value=0)


fn calc_prev_and_next(owned value: Line, last: Int) -> (Int64, Int64):
    idx = 0
    frst, lst = value[0], value[last - 1]
    while value[0] != 0 or value[last - 1 - idx] != 0:
        idx += 1
        value = value.shift_left[1]() - value
        value[last - idx] = 0
        frst = value[0] - frst
        lst += value[last - 1 - idx]
    return frst, lst


fn create_line(v: String) -> (Line, Int):
    values = v.split()
    line = Line(0)

    try:

        @parameter
        for i in range(21):  # all lines have 21 items
            if i >= values.size:
                break
            line[i] = int(values[i])
    except:
        os.abort("bad bad on create line")
        pass

    return (line, values.size)


struct Solution(GenericAdventSolution):
    alias Result: TestMovableResult = Int

    @staticmethod
    fn part_1(lines: List[String]) raises -> Self.Result:
        tot = SIMD[DType.int64, 256](0)

        @parameter
        fn calc(idx: Int):
            # for idx in range(lines.size):
            line, last = create_line(lines[idx])
            _, l = calc_prev_and_next(line, last)
            tot[idx] = l

        parallelize[calc](lines.size)
        return int(tot.reduce_add())

    @staticmethod
    fn part_2(lines: List[String]) raises -> Self.Result:
        tot = SIMD[DType.int64, 256](0)

        @parameter
        fn calc(idx: Int):
            # for idx in range(lines.size):
            line, last = create_line(lines[idx])
            f, _ = calc_prev_and_next(line, last)
            tot[idx] = f

        parallelize[calc](lines.size)
        return int(tot.reduce_add())
