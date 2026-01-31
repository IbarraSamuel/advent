from toml_parser_new import parse_toml
from toml_parser import parse_toml as parse_toml_old
from pathlib import Path, _dir_of_current_file
from benchmark import benchmark


fn main() raises:
    var path = _dir_of_current_file() / "../../advent_config.toml"
    var content = StringSlice(path.read_text())

    # @parameter
    # fn old():
    #     _ = parse_toml_old(content)

    # var old_rep = benchmark.run[old](max_iters=10, max_runtime_secs=0.5)
    # print("old report:")
    # old_rep.print()

    # @parameter
    # fn parse():
    #     _ = parse_toml(content)

    # var report = benchmark.run[parse](max_iters=10, max_runtime_secs=0.5)
    # print("new report:")
    # report.print()

    var toml = parse_toml(content)
    print("toml:", toml)
    ref v = toml["tests"]["year"]["2025"]["day"]["1"]["part"]["1"][0]
    print("part 1 file: ", v["file"], ", expected:", v["expected"])
