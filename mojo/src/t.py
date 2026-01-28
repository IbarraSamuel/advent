from pathlib import Path  # noqa: D100
from time import time_ns
from tomllib import load

with Path(Path(__file__).parent / "../t.toml").open("rb") as f:
    t1 = time_ns()
    result = load(f)
    r = time_ns() - t1
    print(r / 1e9)  # noqa: T201
    print(result)
