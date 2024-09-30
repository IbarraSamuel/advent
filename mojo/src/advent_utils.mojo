from collections.optional import Optional
from os import abort
from testing import assert_equal
from builtin.builtin_list import VariadicList
from testing.testing import Testable
from utils import Variant
from tensor import Tensor
from pathlib import Path

alias FileTensor = Tensor[DType.uint8]
alias SIMDResult = SIMD[DType.uint32, 1024]


fn read_input[path: StringLiteral]() -> List[String]:
    try:
        with open(path, "rt") as f:
            return f.read().splitlines()
    except:
        abort("Error while reading file")

    return List[String]()


fn read_input[path: Path]() -> FileTensor:
    try:
        return FileTensor.fromfile(path)
    except:
        abort("Error while reading file")

    return FileTensor()


fn unwrap_or[
    T: AnyType, O: Movable
](f: fn (T) raises -> O, arg: T, /, owned default: O) -> O:
    try:
        return f(arg)
    except:
        return default^


trait TestResult(Testable):
    ...


trait TestMovableResult(Testable, CollectionElement):
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
        writer.write(str(self))

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


# TODO: Remove raises when it's fixed by mojo team
trait GenericAdventSolution:
    alias Result: TestMovableResult

    @staticmethod
    fn part_1(lines: List[String]) raises -> Result:
        ...

    @staticmethod
    fn part_2(lines: List[String]) raises -> Result:
        ...


trait TensorSolution:
    alias dtype: DType

    @staticmethod
    fn part_1(lines: FileTensor) -> Scalar[dtype]:
        ...

    @staticmethod
    fn part_2(lines: FileTensor) -> Scalar[dtype]:
        ...


fn run[S: AdventSolution, path: StringLiteral]() capturing:
    var input = read_input[path=path]()
    print("From", path, "=>")
    var result_1 = S.part_1(input)
    print("\tPart 1:", result_1)
    var result_2 = S.part_2(input)
    print("\tPart 2:", result_2, end="\n")


fn run[S: GenericAdventSolution, path: StringLiteral]() capturing:
    var input = read_input[path=path]()
    try:
        print("From", path, "=>")
        var result_1 = S.part_1(input)
        print("\tPart 1:", str(result_1))
        var result_2 = S.part_2(input)
        print("\tPart 2:", str(result_2), end="\n")
    except:
        abort("Error while running GenericSolution")


fn run[S: TensorSolution, path: StringLiteral]() capturing:
    var input = read_input[path = Path(path)]()
    print("From", path, "=>")
    var result_1 = S.part_1(input)
    print("\tPart 1:", result_1)
    var result_2 = S.part_2(input)
    print("\tPart 2:", result_2, end="\n")


fn test_solution[
    T: TestMovableResult, //,
    S: AdventSolution,
    test_1: (StringLiteral, T),
    test_2: (StringLiteral, T),
]() raises:
    alias path_1 = test_1[0]
    alias expected_result_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_result_2 = test_2[1]

    result_1 = S.part_1(read_input[path_1]())
    assert_equal(str(result_1), str(expected_result_1))

    result_2 = S.part_2(read_input[path_2]())
    assert_equal(str(result_2), str(expected_result_2))


fn test_solution[
    S: GenericAdventSolution,
    test_1: (StringLiteral, S.Result),
    test_2: (StringLiteral, S.Result),
]() raises:
    alias path_1 = test_1[0]
    alias expected_result_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_result_2 = test_2[1]

    var result_1 = S.part_1(read_input[path_1]())
    assert_equal(result_1, expected_result_1)

    var result_2 = S.part_2(read_input[path_2]())
    assert_equal(result_2, expected_result_2)


fn test_solution[
    S: TensorSolution,
    test_1: (StringLiteral, Scalar[S.dtype]),
    test_2: (StringLiteral, Scalar[S.dtype]),
]() raises:
    alias path_1 = test_1[0]
    alias expected_1 = test_1[1]

    alias path_2 = test_2[0]
    alias expected_2 = test_2[1]

    input_1 = FileTensor.fromfile(Path(path_1))
    result_1 = S.part_1(input_1)
    assert_equal(result_1, expected_1)

    input_2 = FileTensor.fromfile(Path(path_2))
    result_2 = S.part_2(input_2)
    assert_equal(result_2, expected_2)


fn test_solution[
    T: TestMovableResult, //,
    S: AdventSolution,
    *tests: (StringLiteral, (T, T)),
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
            assert_equal(str(result_1), str(expected_result_1))

        if str(expected_result_2) != "0":
            result_2 = S.part_2(input)
            assert_equal(str(result_2), str(expected_result_2))


fn test_solution[
    S: GenericAdventSolution,
    *tests: (StringLiteral, (S.Result, S.Result)),
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_1 = test_list[i][0][1][0]
        alias expected_2 = test_list[i][0][1][1]

        input = read_input[path]()

        if str(expected_1) != "0":
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_1)

        if str(expected_2) != "0":
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_2)


fn test_solution[
    S: TensorSolution,
    *tests: (StringLiteral, (Scalar[S.dtype], Scalar[S.dtype])),
]() raises:
    alias test_list = VariadicList(tests)

    @parameter
    for i in range(len(test_list)):
        alias path = test_list[i][0][0]
        alias expected_1 = test_list[i][0][1][0]
        alias expected_2 = test_list[i][0][1][1]

        input = FileTensor.fromfile(Path(path))

        if str(expected_1) != "0":
            result_1 = S.part_1(input)
            assert_equal(result_1, expected_1)

        if str(expected_2) != "0":
            result_2 = S.part_2(input)
            assert_equal(result_2, expected_2)
