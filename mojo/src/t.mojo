from toml_parser import parse_toml
from pathlib import Path, _dir_of_current_file
from benchmark import benchmark


fn main() raises:
    var path = _dir_of_current_file() / "../../advent_config.toml"
    var content = path.read_text()

    @parameter
    fn parse():
        _ = parse_toml(content)

    var report = benchmark.run[parse](max_iters=1000, max_runtime_secs=0.5)
    report.print()
