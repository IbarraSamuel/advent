from std.testing import assert_equal
from std.pathlib import _dir_of_current_file, Path

from motoml.types.toml import Toml
from motoml.parser import parse_toml_raises
from motoml.reflection import toml_to_type

from test_suite import TestSuite
from advent_utils import AdventSolution, Args

comptime Years = Dict[Int, Days]
comptime Days = Dict[Int, Parts]
comptime Parts = Dict[Int, TestCases]
comptime TestCases = List[Case]


@fieldwise_init
struct Case(Copyable, Writable):
    var file: Path
    var expected: Int


def parse_config() raises -> Years:
    var loc = _dir_of_current_file() / "../.."
    var config_loc = loc / "advent_config.toml"
    var data = config_loc.read_text()

    var toml = parse_toml_raises(data)
    ref all_years = toml[Toml.Table]["tests"][Toml.Table]["year"]

    return {
        Int(year_kv.key): {
            Int(day_kv.key): {
                Int(part_kv.key): [
                    Case(
                        loc
                        / "tests"
                        / year_kv.key
                        / test[Toml.Table]["file"][Toml.String],
                        test[Toml.Table]["expected"][Toml.Integer],
                    )
                    for test in part_kv.value[Toml.Array]
                ]
                for part_kv in day_kv.value[Toml.Table]["part"][
                    Toml.Table
                ].items()
            }
            for day_kv in year_kv.value[Toml.Table]["day"][Toml.Table].items()
        }
        for year_kv in all_years[Toml.Table].items()
    }


def test_solution[year: Int, day: Int, S: AdventSolution, part: Int]() raises:
    var config = parse_config()

    ref test_cases = config[year][day][part]

    for test_case in test_cases:
        comptime runner = S.part_1 if part == 1 else S.part_2
        var content = test_case.file.read_text()
        var res = runner(content)
        assert_equal(Int(res), test_case.expected)


def run_tests[Y: Int, *S: AdventSolution](args: Args, config: Years) raises:
    if not (Y in config and (not args.year or args.year.unsafe_value() == Y)):
        return

    ref day_data = config.find(Y)
    if not day_data:
        print("No value found for key:", Y, "on config:", config)
        return

    var ts = TestSuite()

    comptime for i in range(S.length):
        comptime day = i + 1

        ref parts_data = day_data.unsafe_value().find(day)
        if not parts_data:
            continue

        if args.day and args.day.unsafe_value() != day:
            continue

        comptime for part in range(1, 3):
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
