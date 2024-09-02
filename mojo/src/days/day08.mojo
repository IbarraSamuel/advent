from advent_utils import AdventResult
import sys
from collections import Dict
from math import log, ceil

alias LEFT = "L"
alias RIGHT = "R"


struct Solution:
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        alias Indexer = Dict[String, Int]
        data_len = len(lines[0]) - 3
        init_cap = ceil(log(Float64(data_len)) / log(Float64(2)))
        dct = Indexer(power_of_two_initial_capacity=2 ** int(init_cap))
        key = String("AAA")
        iterations = 0

        for idx in range(3, len(lines)):
            dct[lines[idx][:3]] = idx

        while True:
            outer_break = False

            for chr in lines[0]:
                iterations += 1
                low, up = (7, 10) if chr == LEFT else (12, 15)
                line = lines[dct.get(key, 0)]
                key = line[low:up]

                if key == "ZZZ":
                    outer_break = True
                    break

            if outer_break:
                break

        return iterations

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        return 0
