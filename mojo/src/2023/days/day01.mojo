from advent_utils import SIMDResult
from collections import Dict, Optional
from algorithm.functional import parallelize

alias MapList = [
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9),
    ("1", 1),
    ("2", 2),
    ("3", 3),
    ("4", 4),
    ("5", 5),
    ("6", 6),
    ("7", 7),
    ("8", 8),
    ("9", 9),
]


struct Solution:
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        var total = SIMDResult(0)

        @parameter
        fn calc_line(idx: Int):
            # for idx in range(lines.size):
            f, l = first_numeric(lines[idx])
            total[idx] = f * 10 + l

        parallelize[calc_line](lines.size)
        return total.reduce_add()

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        var total = SIMDResult(0)

        @parameter
        fn calc_line(idx: Int):
            # for idx in range(lines.size):
            total[idx] = line_value(lines[idx])

        parallelize[calc_line](lines.size)
        return total.reduce_add()


fn first_numeric(line: String) -> (Int, Int):
    pos, end = 0, len(line) - 1
    fval, lval = 0, 0

    while pos <= end:
        if not fval:
            try:
                fval = Int(line[pos])
            except:
                pass
        if not lval:
            try:
                lval = Int(line[end - pos])
            except:
                pass

        if not fval or not lval:
            pos += 1
        elif fval and lval:
            return fval, lval

    return fval, lval


fn line_value(line: String) -> Int:
    var first_v = 0
    var first_idx: Int = -1
    var last_v = 0
    var last_idx: Int = -1

    @parameter
    for idx in range(len(MapList)):
        k, v = MapList.get[idx, (StringLiteral, Int)]()
        var mn = line.find(k)
        var mx = line.rfind(k)

        if first_idx == -1 or mn != -1 and mn < first_idx:
            first_v, first_idx = v, mn

        if last_idx == -1 or mx != -1 and mx > last_idx:
            last_v, last_idx = v, mx

    return first_v * 10 + last_v
