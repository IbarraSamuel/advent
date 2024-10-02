from advent_utils import (
    AdventResult,
    SIMDResult,
    GenericAdventSolution,
    TestMovableResult,
)
import sys
from collections import Dict, Optional
from utils import StaticIntTuple
from math import log, ceil
from algorithm import parallelize

alias LEFT = "L"
alias RIGHT = "R"
alias Indexer = Dict[String, Int]

alias default_lpv = List[StaticIntTuple[2]]()


fn lcm[tp: DType, //](first: Scalar[tp], second: Scalar[tp]) -> Scalar[tp]:
    mn, mx = (first, second) if first < second else (second, first)
    while mx % mn != 0:
        mn, mx = mx % mn, mn
    return first * second // mn


@always_inline
fn ceil_2pow(v: Int) -> Int:
    return 2 ** int(ceil(log(Float64(v)) / log(Float64(2))))


@always_inline
fn key_in_list(k: Int, lstp: List[StaticIntTuple[2]]) -> Optional[Int]:
    for tp in lstp:
        if tp[][0] == k:
            return Optional(tp[][1])

    return None


struct Solution(GenericAdventSolution):
    alias Result: TestMovableResult = Int

    @staticmethod
    fn part_1(lines: List[String]) raises -> Int:
        data_len = lines.size - 2
        dct = Indexer(power_of_two_initial_capacity=ceil_2pow(data_len))
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
    fn part_2(lines: List[String]) raises -> Int:
        data_len = lines.size
        iter_len = lines[0].byte_length()
        dct = Indexer(power_of_two_initial_capacity=ceil_2pow(data_len - 2))

        init_nodes = List[Int](capacity=8)
        loop_values = List[List[StaticIntTuple[2]]](capacity=8)

        for idx in range(2, lines.size):
            dct[lines[idx][:3]] = idx
            if lines[idx][2] == "A":
                init_nodes.append(idx)
                loop_values.append(default_lpv)

        results = SIMDResult(0)

        @parameter
        fn calc_cycles(idx: Int):
            init = lines[init_nodes[idx]][:3]
            done = False
            loop_no = 0
            z_values = Dict[String, Int]()
            while not done:
                for i in range(iter_len):
                    if init.endswith("Z"):
                        if init in z_values:
                            results[idx] = (
                                i + data_len * loop_no
                            ) - z_values.get(init).value()
                            return
                        z_values[init] = i + data_len * loop_no
                    init = (
                        lines[dct.get(init).value()][7:10] if lines[0][i]
                        == LEFT else lines[dct.get(init).value()][12:15]
                    )
                loop_no += 1

        parallelize[calc_cycles](init_nodes.size)

        first = results[0]
        for v in range(init_nodes.size - 1):
            first = lcm(first, results[v + 1])
        return int(first)
