from toml_parser import parse_toml, stringify_toml
from pathlib import Path
from sys import argv
from utils import Variant
import os


fn main() raises:
    var path = argv()[1]
    var f = Path(path).read_text()
    var t = parse_toml(f)
    print("parsed toml:", t)
