from advent_utils import AdventSolution
from tensor import Tensor

alias `,` = ord(",")


struct Solution(AdventSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(data: List[String]) -> Scalar[Self.dtype]:
        t = 0
        acc = 0
        d = data[0].as_bytes()
        for v in d:
            if v[] == `,`:
                t += int(acc)
                acc = 0
                continue
            acc = ((acc + int(v[])) * 17) % 256
        return t + acc

    @staticmethod
    fn part_2(data: List[String]) -> Scalar[Self.dtype]:
        return 0
