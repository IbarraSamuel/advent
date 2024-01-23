from __future__ import annotations


def reflection_row(block: list[str]) -> int:
    return next(
        (
            idx
            for idx in range(1, len(block))
            if all(
                left == right for left, right in zip(reversed(block[:idx]), block[idx:])
            )
        ),
        0,
    )


def score_block(block: str) -> int:
    rows = block.split("\n")
    return reflection_row(rows) * 100 + reflection_row(list(zip(*rows)))
    if row := reflection_row(rows):
        return 100 * row

    if col := reflection_row(list(zip(*rows))):
        return col

    raise ValueError(f"no reflection found! for {block}.\n{rows}\n{list(zip(*rows))}")


def part_1(input: str) -> int:
    return sum(score_block(block) for block in input.split("\n\n"))


with open("../inputs/day13.txt") as f:
    values = f.read()
    print(part_1(values))
