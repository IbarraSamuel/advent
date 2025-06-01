import sys
from collections import Dict, Optional
from utils import IndexList
from math import log, ceil
from algorithm import parallelize
from advent_utils import ListSolution

alias LEFT = "L"
alias RIGHT = "R"
alias Indexer = Dict[String, Int]

alias default_lpv = List[IndexList[2]]()


fn lcm[tp: DType, //](first: Scalar[tp], second: Scalar[tp]) -> Scalar[tp]:
    mn, mx = (first, second) if first < second else (second, first)
    while mx % mn != 0:
        mn, mx = mx % mn, mn
    return first * second // mn


@always_inline
fn ceil_2pow(v: Int) -> Int:
    return 2 ** Int(ceil(log(Float64(v)) / log(Float64(2))))


@always_inline
fn key_in_list(k: Int, lstp: List[IndexList[2]]) -> Optional[Int]:
    for ref tp in lstp:
        if tp[0] == k:
            return Optional(tp[1])

    return None


struct Solution(ListSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(lines: List[String]) -> UInt32:
        data_len = len(lines) - 2
        dct = Indexer(power_of_two_initial_capacity=ceil_2pow(data_len))
        key = String("AAA")
        iterations = 0

        for idx in range(2, len(lines)):
            dct[lines[idx][:3]] = idx

        loop_on = True
        while loop_on:
            for chr in lines[0].codepoint_slices():
                iterations += 1
                low, up = (7, 10) if chr == LEFT else (12, 15)
                line = lines[dct.get(key, 0)]
                key = line[low:up]

                if key == "ZZZ":
                    loop_on = False
                    break

        return iterations

    @staticmethod
    fn part_2(lines: List[String]) -> UInt32:
        data_len = len(lines)
        iter_len = lines[0].byte_length()
        dct = Indexer(power_of_two_initial_capacity=ceil_2pow(data_len - 2))
        init_nodes = List[Int](capacity=8)

        for idx in range(2, len(lines)):
            dct[lines[idx][:3]] = idx
            if lines[idx][2] == "A":
                init_nodes.append(idx)

        results = SIMD[DType.uint32, 8](0)

        @parameter
        fn calc_cycles(idx: Int):
            pos = lines[init_nodes[idx]][:3]
            done = False
            loop_no = 0
            readed = Dict[String, Int](power_of_two_initial_capacity=128)
            while not done:
                for i in range(iter_len):
                    if pos in readed:
                        results[idx] = (i + iter_len * loop_no) - readed.get(
                            pos
                        ).value()
                        break

                    readed[pos] = i + iter_len * loop_no

                    pos = (
                        lines[dct.get(pos).value()][7:10] if lines[0][i]
                        == LEFT else lines[dct.get(pos).value()][12:15]
                    )
                if results[idx] != 0:
                    break
                loop_no += 1

        parallelize[calc_cycles](len(init_nodes))

        first = results[0]
        for v in range(len(init_nodes) - 1):
            first = lcm(first, results[v + 1])
        return first
