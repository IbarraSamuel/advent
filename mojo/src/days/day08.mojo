from advent_utils import AdventResult
import sys
from collections import Dict, Optional
from utils import StaticIntTuple
from math import log, ceil
from algorithm import parallelize

alias LEFT = "L"
alias RIGHT = "R"

alias default_lpv = List[StaticIntTuple[2]]()


fn lcm(first: Int, second: Int) -> Int:
    mn, mx = (first, second) if first < second else (second, first)
    while mx % mn != 0:
        mn, mx = mx % mn, mn
    return first * second // mn


@always_inline
fn ceil_power_of_two(v: Int) -> Int:
    return 2 ** int(ceil(log(Float64(v)) / log(Float64(2))))


@always_inline
fn key_in_list(k: Int, lstp: List[StaticIntTuple[2]]) -> Optional[Int]:
    for tp in lstp:
        if tp[][0] == k:
            return Optional(tp[][1])

    return None


struct Solution:
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        alias Indexer = Dict[String, Int]
        data_len = lines[0].byte_length() - 2
        dct = Indexer(power_of_two_initial_capacity=ceil_power_of_two(data_len))
        key = String("AAA")
        iterations = 0

        for idx in range(2, lines.size):
            dct[lines[idx][:3]] = idx

        loop_on = True
        while loop_on:
            for chr in lines[0]:
                iterations += 1
                low, up = (7, 10) if chr == LEFT else (12, 15)
                line = lines[dct.get(key, 0)]
                key = line[low:up]

                if key == "ZZZ":
                    loop_on = False
                    break

        return iterations

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        alias Indexer = Dict[String, Int]
        data_len = lines[0].byte_length() - 2
        init_cap = ceil(log(Float64(data_len)) / log(Float64(2)))
        dct = Indexer(power_of_two_initial_capacity=2 ** int(init_cap))
        count = 0

        inits = List[Int](capacity=8)
        loop_values = List[List[StaticIntTuple[2]]](capacity=8)
        ignore = List[Int](capacity=8)
        final_values = List[Int](capacity=8)

        for idx in range(2, lines.size):
            dct[lines[idx][:3]] = idx
            if lines[idx][2] == "A":
                inits.append(idx)
                loop_values.append(default_lpv)

        loop_on = True
        while loop_on:
            for chr in lines[0]:
                count += 1
                low, up = (7, 10) if chr == LEFT else (12, 15)

                for idx in range(len(inits)):
                    key_pos = int(inits[idx])
                    k = lines[key_pos][:3]
                    new_key_pos = dct.get(k).value()
                    new_k = lines[new_key_pos][low:up]
                    if new_k[-1] == "Z":
                        pos = key_in_list(new_key_pos, loop_values[idx])
                        if pos:
                            final_values.append(count - pos.value())
                            ignore.append(idx)
                            continue

                        loop_values[idx].append((new_key_pos, count))
                    inits[idx] = dct.get(new_k).value()

                for i in ignore:
                    _ = inits.pop(i[])
                    _ = loop_values.pop(i[])
                ignore.clear()

                if inits.size == 0:
                    loop_on = False
                    break

        first = final_values[0]
        for v in final_values[1:]:
            first = lcm(first, v[])
        return first
