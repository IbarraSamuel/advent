"""Define all test for given solutions."""

from pathlib import Path
from tomllib import load
from typing import TypedDict, Unpack

import pytest


class Data(TypedDict):
    """Data from toml file."""

    test: Years


class Years(TypedDict):
    """The years mapping of each solution provided."""

    year: dict[int, Day]


class Day(TypedDict):
    """The day to evaluate."""

    day: dict[int, Part]


class Part(TypedDict):
    """The day to evaluate."""

    part: dict[int, list[TestCase]]


class TestCase(TypedDict):
    """Case to evaluate."""

    file: str
    expected: int


class PyTestCase(TypedDict):
    """Test cases."""

    year: int
    day: int
    part: int
    file: str
    expected: int


type CaseValues = tuple[int, int, int, str, int]


def tuple_to_cases(tp: CaseValues) -> PyTestCase:
    """Convert tuple to fields."""
    y, d, p, f, e = tp
    return PyTestCase(year=y, day=d, part=p, file=f, expected=e)


def create_testcases() -> list[CaseValues]:
    """{roduce the pytest values."""
    config = Path(__file__).parent.parent.parent / "advent_config.toml"
    with config.open("rb") as f:
        data: Data = load(f)

    return [
        (y, d, p, c["file"], c["expected"])
        for y, yv in data["test"]["year"].items()
        for d, dv in yv["day"].items()
        for p, lst in dv["part"].items()
        for c in lst
    ]


CASES = create_testcases()


@pytest.mark.parametrize(("year", "day", "part", "file", "expected"), CASES)
def test_solutions(**kwargs: Unpack[PyTestCase]) -> None:
    """Solutions to test."""
    year = kwargs["year"]
    day = kwargs["day"]
    part = kwargs["part"]
    file = kwargs["file"]
    expected = kwargs["expected"]

    print(kwargs)
