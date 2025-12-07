from testing import TestSuite, assert_equal
from advent_utils import AdventSolution
import solutions
from pathlib import _dir_of_current_file, Path
from python import Python, PythonObject
from builtin import Variadic
from sys import argv
import days

alias Years = Dict[Int, Days]
alias Days = Dict[Int, Parts]
alias Parts = Dict[Int, TestCases]
alias TestCases = List[Case]


@fieldwise_init
struct Case(ImplicitlyCopyable):
    var file: Path
    var expected: Int


fn parse_config() raises -> Years:
    var toml = Python.import_module("tomllib")

    var loc = _dir_of_current_file() / "../../.."
    var config_loc = loc / "advent_config.toml"
    var data = config_loc.read_text()

    var py_data = toml.loads(data)
    var year_data = py_data[PythonObject("tests")][PythonObject("year")]
    # print("year data:", year_data)

    var years = Years()
    for yi in year_data.items():
        var year, day_data = yi[0], yi[1][PythonObject("day")]
        # print("\tdays data for year:", year, "is:", day_data)

        var days = Days()
        for di in day_data.items():
            var day, part_data = di[0], di[1][PythonObject("part")]
            # print("\t\tparts data for day:", day, "is:", part_data)

            var parts = Parts()
            for pi in part_data.items():
                var part, test_list = pi[0], pi[1]
                # print("\t\t\ttest list for part:", part, "is:", test_list)

                var cases = TestCases()
                for t in test_list:
                    file_location, test_expects = (
                        t[PythonObject("file")],
                        t[PythonObject("expected")],
                    )

                    var floc = (
                        loc / "tests" / String(year) / String(file_location)
                    )
                    var tcase = Case(floc, Int(test_expects))
                    cases.append(tcase^)

                parts[Int(part)] = cases^

            days[Int(day)] = parts^

        years[Int(year)] = days^

    return years^


@fieldwise_init
struct Args:
    var year: Optional[Int]
    var day: Optional[Int]
    var part: Optional[Int]


fn parse_args() raises -> Args:
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

    return {year, day, part}


fn test_from_config[year: Int, *Solutions: AdventSolution]() raises:
    var args = parse_args()
    var config = parse_config()

    @parameter
    for i in range(Variadic.size(Solutions)):
        alias S = Solutions[i]

        if args.day and i + 1 != args.day.unsafe_value():
            continue

        var d: Int = i + 1 if not args.day else args.day.unsafe_value()
        ref days_data = config.find(year)

        if not days_data:
            raise "provided year {} is not configured on the config file.".format(
                year
            )

        ref part_to_cases_map = days_data.unsafe_value().find(d)

        if not part_to_cases_map:
            raise "provided day {} is not configured for year: {} in the config file.".format(
                d, args.year
            )

        @parameter
        for part in range(2):
            alias p = part + 1
            if not args.part or args.part.unsafe_value() == p:
                var test_cases = part_to_cases_map.unsafe_value().get(p)
                if not test_cases:
                    raise "provided part {} for day {} for year {} is not in the config file.".format(
                        p, d, year
                    )

                for test_case in test_cases.unsafe_value():
                    alias runner = S.part_1 if p == 1 else S.part_2
                    var res = Int(runner(test_case.file.read_text()))
                    var status = (
                        "PASSED" if res == test_case.expected else "FAILED"
                    )
                    print(
                        "[TEST] [{}] Year {} Day {} Part {} file {}"
                        " (result: {} vs expected: {})".format(
                            status,
                            year,
                            d,
                            p,
                            test_case.file.name(),
                            res,
                            test_case.expected,
                        )
                    )
                    assert_equal(res, test_case.expected)


fn main() raises:
    var args = parse_args()
    var ts = TestSuite(cli_args=List[StaticString]())

    @parameter
    for year_it in solutions.Solutions:
        alias Y, S = year_it
        if not args.year or args.year.unsafe_value() == Y:
            ts.test[test_from_config[Y, *S]]()
    ts^.run()
