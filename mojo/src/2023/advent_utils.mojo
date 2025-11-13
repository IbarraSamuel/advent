from testing import assert_equal
from pathlib import _dir_of_current_file
from time import time_function

alias SIMDResult = SIMD[DType.uint32, 1024]
alias CollectionElement = Copyable & Movable


fn read_input_lines[path: StaticString]() raises -> String:
    p = _dir_of_current_file().joinpath("../../../" + path)
    with open(p, "r") as f:
        return f.read()


trait ListSolution:
    alias dtype: DType

    @staticmethod
    fn part_1[o: Origin](lines: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        ...

    @staticmethod
    fn part_2[o: Origin](lines: List[StringSlice[o]]) -> Scalar[Self.dtype]:
        ...


fn get_solutions[S: ListSolution, I: StringLiteral]() raises -> Tuple[Int, Int]:
    input = read_input_lines[I]().splitlines()
    p1 = S.part_1(input)
    p2 = S.part_2(input)
    return Int(p1), Int(p2)


fn run[S: ListSolution, path: StringLiteral]() raises:
    var input = read_input_lines[path=path]().splitlines()
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
    print("\tPart 2:", r2, "in", t2, "us.", end="\n\n")


fn test_solution[
    S: ListSolution,
    test_1: Tuple[StaticString, Int],
    test_2: Tuple[StaticString, Int],
]() raises:
    alias path_1: StaticString = test_1[0]
    alias expected_result_1: Int = test_1[1]

    alias path_2: StaticString = test_2[0]
    alias expected_result_2: Int = test_2[1]

    result_1 = S.part_1(read_input_lines[path_1]().splitlines())
    assert_equal(result_1, expected_result_1)

    result_2 = S.part_2(read_input_lines[path_2]().splitlines())
    assert_equal(result_2, expected_result_2)


fn test_solution[
    S: ListSolution, *tests: Tuple[StaticString, Tuple[Int, Int]]
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path: StaticString = test_list[i][0][0]
        alias expected_result_1: Int = test_list[i][0][1][0]
        alias expected_result_2: Int = test_list[i][0][1][1]

        input = read_input_lines[path=path]().splitlines()

        if expected_result_1 != -1:
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_result_1)

        if expected_result_2 != -1:
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_result_2)
