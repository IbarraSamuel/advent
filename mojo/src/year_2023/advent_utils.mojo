from collections.optional import Optional
from os import abort
from testing import assert_equal
from builtin.builtin_list import VariadicList
from testing.testing import Testable
from utils import Variant, Span
from tensor import Tensor
from pathlib import Path, _dir_of_current_file
from time import time_function
from math import sqrt, ceil

alias FileTensor = Tensor[DType.uint8]
alias SIMDResult = SIMD[DType.uint32, 1024]


fn read_input[path: StringLiteral]() raises -> String:
    p = _dir_of_current_file().joinpath("../../../" + path)
    with open(p, "rt") as f:
        return f.read()


fn read_input_lines[path: StringLiteral]() raises -> List[String]:
    p = _dir_of_current_file().joinpath("../../../" + path)
    with open(p, "rt") as f:
        return f.read().splitlines()


fn read_input_as_tensor[path: StringLiteral]() raises -> FileTensor:
    p = _dir_of_current_file().joinpath("../../../" + path)
    t = FileTensor.fromfile(p)

    # Adjusting Tensor
    prev_y = t.bytecount()

    i = 0
    while True:
        if t[i] == ord("\n"):
            break
        i += 1

    map = FileTensor(
        shape=((prev_y + 1) // (i + 1), i + 1),
        ptr=t._take_data_ptr(),
    )

    map[prev_y] = ord("\n")
    # End of Tensor Adjust
    return map


@always_inline("nodebug")
fn ceil_pow_of_two(v: Int) -> Int:
    return int(ceil(sqrt(float(v))) ** 2)


fn filter[
    elem: CollectionElement, //,
    *filters: fn (elem) -> Bool,
    negate: Bool = False,
](owned list: List[elem]) -> List[elem]:
    alias fltrs = VariadicList(filters)
    i = list.size - 1
    while i >= 0:
        to_delete = False

        @parameter
        for f in range(len(fltrs)):
            to_delete = fltrs[f](list[i]) ^ negate

        if to_delete:
            _ = list.pop(i)

        i -= 1
    return list


fn map[
    elem: CollectionElement,
    out: CollectionElement, //,
    mapper: fn (elem) -> out,
](list: List[elem]) -> List[out]:
    final = List[out](capacity=list.size)
    for value in list:
        final.append(mapper(value[]))
    return final


fn map[
    elem: CollectionElement,
    out: CollectionElement, //,
    mapper: fn (elem) raises -> out,
](list: List[elem]) raises -> List[out]:
    final = List[out](capacity=list.size)
    for value in list:
        final.append(mapper(value[]))
    return final


trait ListSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[dtype]:
        ...


trait StringSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(lines: String) -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(lines: String) -> Scalar[dtype]:
        ...


trait TensorSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(owned lines: FileTensor) raises -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(owned lines: FileTensor) raises -> Scalar[dtype]:
        ...


# fn get_solutions[S: ListSolution, I: StringLiteral]() raises -> (Int, Int):
#     input = read_input_lines[I]()
#     p1 = S.part_1(input)
#     p2 = S.part_2(input)
#     return int(p1), int(p2)


# fn get_solutions[S: StringSolution, I: StringLiteral]() raises -> (Int, Int):
#     input = read_input[I]()
#     p1 = S.part_1(input)
#     p2 = S.part_2(input)
#     return int(p1), int(p2)


# fn get_solutions[S: TensorSolution, I: StringLiteral]() raises -> (Int, Int):
#     input = read_input_as_tensor[I]()
#     p1 = S.part_1(input)
#     p2 = S.part_2(input)
#     return int(p1), int(p2)


fn run[S: ListSolution, path: StringLiteral]() raises:
    var input = read_input_lines[path=path]()
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


fn run[S: StringSolution, path: StringLiteral]() raises:
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


fn run[S: TensorSolution, path: StringLiteral]() raises:
    var input = read_input_as_tensor[path=path]()
    print("From", path, "=>")

    var r1: Scalar[S.dtype] = 0

    @parameter
    fn part_1() raises:
        r1 = S.part_1(input)

    t1 = time_function[func=part_1]() // 10e3
    print("\tPart 1:", r1, "in", t1, "us.")

    var r2: Scalar[S.dtype] = 0

    @parameter
    fn part_2() raises:
        r2 = S.part_2(input)

    t2 = time_function[func=part_2]() // 10e3
    print("\tPart 2:", r2, "in", t2, "us.", end="\n")


fn test_solution[
    S: ListSolution,
    test_1: (StringLiteral, Int),
    test_2: (StringLiteral, Int),
]() raises:
    alias path_1 = test_1[0]
    alias expected_result_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_result_2 = test_2[1]

    result_1 = S.part_1(read_input_lines[path_1]())
    assert_equal(result_1, expected_result_1)

    result_2 = S.part_2(read_input_lines[path_2]())
    assert_equal(result_2, expected_result_2)


fn test_solution[S: ListSolution, *tests: (StringLiteral, (Int, Int))]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_result_1 = test_list[i][0][1][0]
        alias expected_result_2 = test_list[i][0][1][1]

        input = read_input_lines[path=path]()

        if str(expected_result_1) != "-1":
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_result_1)

        if str(expected_result_2) != "-1":
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_result_2)


fn test_solution[
    S: StringSolution,
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
    S: StringSolution, *tests: (StringLiteral, (Int, Int))
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_result_1 = test_list[i][0][1][0]
        alias expected_result_2 = test_list[i][0][1][1]

        input = read_input[path=path]()

        if str(expected_result_1) != "-1":
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_result_1)

        if str(expected_result_2) != "-1":
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_result_2)


fn test_solution[
    S: TensorSolution,
    test_1: (StringLiteral, Int),
    test_2: (StringLiteral, Int),
]() raises:
    alias path_1 = test_1[0]
    alias expected_result_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_result_2 = test_2[1]

    result_1 = S.part_1(read_input_as_tensor[path_1]())
    assert_equal(result_1, expected_result_1)

    result_2 = S.part_2(read_input_as_tensor[path_2]())
    assert_equal(result_2, expected_result_2)


fn test_solution[
    S: TensorSolution, *tests: (StringLiteral, (Int, Int))
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_result_1 = test_list[i][0][1][0]
        alias expected_result_2 = test_list[i][0][1][1]

        input = read_input_as_tensor[path=path]()

        if str(expected_result_1) != "-1":
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_result_1)

        if str(expected_result_2) != "-1":
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_result_2)
