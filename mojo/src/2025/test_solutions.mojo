from testing import TestSuite, assert_equal
from advent_utils import AdventSolution
from pathlib import _dir_of_current_file, Path
from builtin import Variadic
from python import Python
from sys import argv
import days

alias Years = Dict[Int, Days]
alias Days = Dict[Int, Parts]
alias Parts = Dict[Int, TestCases]
alias TestCases = List[Case]


@fieldwise_init
struct Case(Copyable, Movable):
    var file: Path
    var expected: Int


fn _parse_to_config(data: StringSlice) raises -> Years:
    var toml = Python.import_module("tomllib")

    var loc = _dir_of_current_file() / "../../.."

    var py_data = toml.loads(data)
    var year_data = py_data["advent"]

    var years = Years()
    for yi in year_data.items():
        var year, day_data = yi[0], yi[1]["day"]

        var days = Days()
        for di in day_data.items():
            var day, part_data = di[0], di[1]["part"]

            var parts = Parts()
            for pi in part_data.items():
                var part, test_list = pi[0], pi[1]

                var cases = TestCases()
                for t in test_list:
                    file_location, test_expects = t[0], t[1]

                    var floc = (
                        loc / "tests" / String(year) / String(file_location)
                    )
                    var tcase = Case(floc, Int(test_expects))
                    cases.append(tcase^)

                parts[Int(part)] = cases^

            days[Int(day)] = parts^

        years[Int(year)] = days^

    return years^


fn test_from_config[
    Solutions: Variadic.TypesOfTrait[AdventSolution]
](config_file: StringSlice) raises:
    var args = argv()

    var year: Optional[Int] = None
    var day: Optional[Int] = None
    var part: Optional[Int] = None

    for i, arg in enumerate(args):
        if arg == "-y":
            year = Int(args[i + 1])
        if arg == "-d":
            day = Int(args[i + 1])
        if arg == "-p":
            part = Int(args[i + 1])

    if not year:
        raise "You should define a year."

    var pkg = _dir_of_current_file() / "../../.." / config_file
    var data = pkg.read_text()
    var config = _parse_to_config(data)

    @parameter
    for i in range(Variadic.size(Solutions)):
        alias S = Solutions[i]

        if day and i + 1 != day[]:
            continue

        var d: Int = i + 1 if not day else day[]

        if not part or part[] == 1:
            for test_case in config[year[]][d][1]:
                var res = S.part_1(test_case.file.read_text())
                assert_equal(Int(res), test_case.expected)

        if not part or part[] == 2:
            for test_case in config[year[]][d][2]:
                var res = S.part_2(test_case.file.read_text())
                assert_equal(Int(res), test_case.expected)


comptime SOLUTIONS = Variadic.types[
    T=AdventSolution,
    days.day01.Solution,
    days.day02.Solution,
    days.day03.Solution,
    days.day04.Solution,
    days.day05.Solution,
]


fn test_all_config() raises:
    # TODO: try to make it configurable
    test_from_config[SOLUTIONS]("config.toml")


fn main() raises:
    print("hi")
    print([a for a in argv()])
    TestSuite.discover_tests[(test_all_config,)]().run()
