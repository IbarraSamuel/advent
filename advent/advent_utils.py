"""Utility functions for Advent of Code."""
import polars as pl


def read_input(path: str, sep: str = ",", *, header: bool = False) -> pl.DataFrame:
    """Read input file into a polars DataFrame."""
    return pl.read_csv(path, separator=sep, has_header=header)
