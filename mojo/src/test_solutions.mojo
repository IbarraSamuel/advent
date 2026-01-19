from testing import assert_equal
from test_suite import TestSuite
from advent_utils import AdventSolution, Solutions, Args
from pathlib import _dir_of_current_file, Path
from python import Python, PythonObject
from builtin import Variadic
from sys import argv

comptime Years = Dict[Int, Days]
comptime Days = Dict[Int, Parts]
comptime Parts = Dict[Int, TestCases]
comptime TestCases = List[Case]


@fieldwise_init
struct Case(Copyable):
    var file: Path
    var expected: Int


fn parse_config() raises -> Years:
    # TODO:NOT USE PYTHON HERE IF POSSIBLE.
    var toml = Python.import_module("tomllib")

    var loc = _dir_of_current_file() / "../.."
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
                    var tcase = Case(floc, Int(py=test_expects))
                    cases.append(tcase^)

                parts[Int(py=part)] = cases^

            days[Int(py=day)] = parts^

        years[Int(py=year)] = days^

    return years^


fn test_solution[year: Int, day: Int, S: AdventSolution, part: Int]() raises:
    var args = Args()
    var config = parse_config()

    ref test_cases = config[year][day][part]

    for test_case in test_cases:
        comptime runner = S.part_1 if part == 1 else S.part_2
        var res = Int(runner(test_case.file.read_text()))
        assert_equal(res, test_case.expected)


fn run_tests[Y: Int, *S: AdventSolution](args: Args, config: Years) raises:
    if not (Y in config and (not args.year or args.year.unsafe_value() == Y)):
        return

    ref day_data = config.find(Y)
    if not day_data:
        return

    var ts = TestSuite()

    @parameter
    for i in range(Variadic.size(S)):
        comptime day = i + 1

        ref parts_data = day_data.unsafe_value().find(day)
        if not parts_data:
            continue

        if args.day and args.day.unsafe_value() != day:
            continue

        @parameter
        for part in range(1, 3):
            ref part_list = parts_data.unsafe_value().find(part)
            if not part_list:
                continue

            if args.part and args.part.unsafe_value() != part:
                continue

            comptime tname: StaticString = String(
                "Year ", Y, " Day ", day, " Part ", part
            )
            ts.test[test_solution[Y, day, S[i], part]](tname)

    ts^.run()
