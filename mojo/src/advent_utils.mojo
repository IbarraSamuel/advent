from collections.optional import Optional
from os import abort
from testing import assert_equal
from builtin.builtin_list import VariadicList
from testing.testing import Testable
from utils import Variant
from tensor import Tensor
from pathlib import Path
from time import time_function

alias FileTensor = Tensor[DType.uint8]
alias SIMDResult = SIMD[DType.uint32, 1024]


fn read_input[path: StringLiteral]() raises -> List[String]:
    with open(path, "rt") as f:
        return f.read().splitlines()


fn read_input[path: Path]() raises -> FileTensor:
    return FileTensor.fromfile(path)


trait AdventSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[dtype]:
        ...


trait TensorSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(lines: FileTensor) -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(lines: FileTensor) -> Scalar[dtype]:
        ...


fn run[S: AdventSolution, path: StringLiteral]() raises:
    var input = read_input[path=path]()
    print("From", path, "=>")

    var r1: Scalar[S.dtype] = 0

    @parameter
    fn part_1():
        r1 = S.part_1(input)

    t1 = time_function[func=part_1]() // 10e3
    print("\tPart 1:", r1, "in", t1, "us.")

    var r2: Scalar[S.dtype] = 0

    @parameter
    fn part_2():
        r2 = S.part_2(input)

    t2 = time_function[func=part_2]() // 10e3
    print("\tPart 2:", r2, "in", t2, "us.", end="\n")


fn test_solution[
    S: AdventSolution,
    test_1: (StringLiteral, Int),
    test_2: (StringLiteral, Int),
]() raises:
    alias path_1 = test_1[0]
    alias expected_result_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_result_2 = test_2[1]

    result_1 = S.part_1(read_input[path_1]())
    assert_equal(result_1, expected_result_1)

    result_2 = S.part_2(read_input[path_2]())
    assert_equal(result_2, expected_result_2)


fn test_solution[
    S: AdventSolution, *tests: (StringLiteral, (Int, Int))
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_result_1 = test_list[i][0][1][0]
        alias expected_result_2 = test_list[i][0][1][1]

        input = read_input[path=path]()

        if str(expected_result_1) != "0":
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_result_1)

        if str(expected_result_2) != "0":
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_result_2)
