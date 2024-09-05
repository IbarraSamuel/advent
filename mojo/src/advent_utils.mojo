from collections.optional import Optional
import sys
from testing import assert_equal
from builtin.builtin_list import VariadicList
from testing.testing import Testable
from utils import Variant


fn read_input[path: StringLiteral]() raises -> List[String]:
    with open(path, "r") as f:
        return f.read().splitlines()


fn unwrap_or[
    T: AnyType, O: Movable
](f: fn (T) raises -> O, arg: T, /, owned default: O) -> O:
    try:
        return f(arg)
    except:
        return default^


trait TestResult(Formattable, Testable):
    ...


trait TestMovableResult(Formattable, Testable, Movable):
    ...


@value
struct AdventResult(TestMovableResult):
    var value: Variant[String, Int, UInt]

    fn __str__(self) -> String:
        if self.value.isa[String]():
            return self.value[String]
        if self.value.isa[Int]():
            return str(self.value[Int])
        if self.value.isa[UInt]():
            return str(self.value[UInt])
        return "This is unreachable!"

    fn format_to(self, inout writer: Formatter):
        var str_self = str(self)
        writer.write(str_self)

    fn __eq__(self, other: Self) -> Bool:
        if self.value.isa[String]() and other.value.isa[String]():
            return self.value[String] == other.value[String]
        if self.value.isa[Int]() and other.value.isa[Int]():
            return self.value[Int] == other.value[Int]
        if self.value.isa[UInt]() and other.value.isa[UInt]():
            return self.value[UInt] == other.value[UInt]

        return False

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


trait AdventSolution:
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        ...

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        ...


fn run[S: AdventSolution, path: StringLiteral]() raises:
    var input = read_input[path=path]()
    print("From", path, "=>")
    var result_1 = S.part_1(input)
    print("\tPart 1:", result_1)
    var result_2 = S.part_2(input)
    print("\tPart 2:", result_2, end="\n")


fn test_solution[
    T: TestResult, //,
    S: AdventSolution,
    path: StringLiteral,
    expected_result_1: T,
    expected_result_2: T,
]() raises:
    var input = read_input[path=path]()
    var result_1 = S.part_1(input)
    assert_equal(str(result_1), str(expected_result_1))
    var result_2 = S.part_2(input)
    assert_equal(str(result_2), str(expected_result_2))


fn test_solution[
    T: TestMovableResult, //,
    S: AdventSolution,
    test_1: Tuple[StringLiteral, T],
    test_2: Tuple[StringLiteral, T],
]() raises:
    alias path_1: StringLiteral = test_1[0]
    alias expected_result_1: T = test_1[1]

    alias path_2: StringLiteral = test_2[0]
    alias expected_result_2: T = test_2[1]

    var result_1 = S.part_1(read_input[path=path_1]())
    assert_equal(str(result_1), str(expected_result_1))

    var result_2 = S.part_2(read_input[path=path_2]())
    assert_equal(str(result_2), str(expected_result_2))


fn test_solution[
    T: TestMovableResult, //,
    S: AdventSolution,
    *tests: Tuple[StringLiteral, Tuple[T, T]],
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path: StringLiteral = test_list[i][0][0]
        alias expected_result_1: T = test_list[i][0][1][0]
        alias expected_result_2: T = test_list[i][0][1][1]

        if str(expected_result_1) != "0":
            var result_1 = S.part_1(read_input[path=path]())
            assert_equal(str(result_1), str(expected_result_1))

        if str(expected_result_2) != "0":
            var result_2 = S.part_2(read_input[path=path]())
            assert_equal(str(result_2), str(expected_result_2))
