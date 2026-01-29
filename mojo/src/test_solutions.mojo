from testing import assert_equal
from test_suite import TestSuite
from advent_utils import AdventSolution, Args
from toml_parser import parse_toml
from pathlib import _dir_of_current_file, Path
from builtin import Variadic

comptime Years = Dict[Int, Days]
comptime Days = Dict[Int, Parts]
comptime Parts = Dict[Int, TestCases]
comptime TestCases = List[Case]


@fieldwise_init
struct Case(Copyable):
    var file: Path
    var expected: Int


fn parse_config() raises -> Years:
    var loc = _dir_of_current_file() / "../.."
    var config_loc = loc / "advent_config.toml"
    var data = config_loc.read_text()

    var toml = parse_toml(data)
    ref all_years = toml["tests"]["year"]

    return {
        Int(year): {
            Int(day): {
                Int(part): [
                    Case(
                        loc / "tests" / year / test["file"].string(),
                        test["expected"].integer(),
                    )
                    for test in part_tests
                ]
                for part, part_tests in day_data["part"].items()
            }
            for day, day_data in year_data["day"].items()
        }
        for year, year_data in all_years.items()
    }


fn test_solution[year: Int, day: Int, S: AdventSolution, part: Int]() raises:
    var config = parse_config()

    ref test_cases = config[year][day][part]

    for test_case in test_cases:
        comptime runner = S.part_1 if part == 1 else S.part_2
        var content = test_case.file.read_text()
        var res = runner(content)
        assert_equal(Int(res), test_case.expected)


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
