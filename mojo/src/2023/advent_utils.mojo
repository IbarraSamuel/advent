from testing import assert_equal
from pathlib import _dir_of_current_file
from time import time_function

alias SIMDResult = SIMD[DType.uint32, 1024]
alias CollectionElement = Copyable & Movable


fn read_input_lines[path: StaticString]() raises -> List[String]:
    p = _dir_of_current_file().joinpath("../../../" + path)
    with open(p, "rt") as f:
        return f.read().splitlines()


fn filter[
    elem: CollectionElement, //,
    *filters: fn (elem) -> Bool,
    negate: Bool = False,
](owned list: List[elem]) -> List[elem]:
    alias fltrs = VariadicList(filters)
    i = len(list) - 1
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
    final = List[out](capacity=len(list))
    for ref value in list:
        final.append(mapper(value))
    return final


fn map[
    elem: CollectionElement,
    out: CollectionElement, //,
    mapper: fn (elem) raises -> out,
](list: List[elem]) raises -> List[out]:
    final = List[out](capacity=len(list))
    for ref value in list:
        final.append(mapper(value))
    return final


trait ListSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[dtype]:
        ...


fn get_solutions[S: ListSolution, I: StringLiteral]() raises -> (Int, Int):
    input = read_input_lines[I]()
    p1 = S.part_1(input)
    p2 = S.part_2(input)
    return Int(p1), Int(p2)


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
    print("\tPart 2:", r2, "in", t2, "us.", end="\n\n")


fn test_solution[
    S: ListSolution,
    test_1: (StaticString, Int),
    test_2: (StaticString, Int),
]() raises:
    alias path_1 = test_1[0]
    alias expected_result_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_result_2 = test_2[1]

    result_1 = S.part_1(read_input_lines[path_1]())
    assert_equal(result_1, expected_result_1)

    result_2 = S.part_2(read_input_lines[path_2]())
    assert_equal(result_2, expected_result_2)


fn test_solution[S: ListSolution, *tests: (StaticString, (Int, Int))]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_result_1 = test_list[i][0][1][0]
        alias expected_result_2 = test_list[i][0][1][1]

        input = read_input_lines[path=path]()

        if expected_result_1 != -1:
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_result_1)

        if expected_result_2 != -1:
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_result_2)
