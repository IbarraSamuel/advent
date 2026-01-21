from toml_parser import parse_toml, stringify_toml
from pathlib import Path


fn main() raises:
    var f = Path("../../advent_config.toml").read_text()
    var result = stringify_toml(f)
    print(result)
