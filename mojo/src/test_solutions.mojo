from std.testing import assert_equal
from std.pathlib import _dir_of_current_file, Path

from motoml.types.toml import Toml
from motoml.parser import parse_toml_raises
from motoml.reflection import toml_to_type
from motoml.mmap_file import MappedFile

from test_suite import TestSuite
from advent_utils import AdventSolution, Args, Part

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
    var data = MappedFile(config_loc).unsafe_view()

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


def test_solution[year: Int, day: Int, S: AdventSolution, part: Part]() raises:
    var config = parse_config()
    ref day_tests = config[year][day]
    comptime match part:
        case .one:
            comptime runner = S.part_1
            for test_case in day_tests[1]:
                var content = MappedFile(test_case.file).unsafe_view()
                var res = runner(content)
                assert_equal(Int(res), test_case.expected)
        case .two:
            comptime runner = S.part_2
            for test_case in day_tests[2]:
                var content = MappedFile(test_case.file).unsafe_view()
                var res = runner(content)
                assert_equal(Int(res), test_case.expected)


def run_tests[Y: Int, *S: AdventSolution](args: Args, config: Years) raises:
    if not (Y in config and (not args.year or args.year.unsafe_value() == Y)):
        return

    ref opt_day_data = config.find(Y)

    if case .None = opt_day_data:
        print("No value found for key:", Y, "on config:", config)
        return

    ref day_data = opt_day_data.unsafe_value()
    var ts = TestSuite()

    comptime for i in range(S.length):
        comptime day = i + 1

        ref parts_data_opt = day_data.find(day)
        if case .None = parts_data_opt:
            continue

        match args.day:
            case .Some(d) if d != day:
                continue
            case _:
                pass

        ref parts_data = parts_data_opt.unsafe_value()

        comptime for part in range(1, 3):
            comptime compt_part = Part.one if part == 1 else Part.two
            if case .None = parts_data.find(part):
                continue

            match (args.part, compt_part):
                case (.Some(.one), .two):
                    continue
                case (.Some(.two), .one):
                    continue
                case _:
                    pass

            comptime tname: StaticString = String(
                "Year ", Y, " Day ", day, " Part ", part
            )
            ts.test[test_solution[Y, day, S[i], compt_part], tname]()

    ts^.run()
