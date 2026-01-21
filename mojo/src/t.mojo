from toml_parser import parse_toml, stringify_toml
from pathlib import Path
from sys import argv


fn main() raises:
    var path = argv()[1]
    var f = Path(path).read_text()
    var result = stringify_toml(f)
    print(result)
