"""Utility functions for Advent of Code."""
from pathlib import Path


def read_input(path: str) -> list[str]:
    """Read input file into a polars DataFrame."""
    with Path(path).open() as f:
        return f.readlines()
