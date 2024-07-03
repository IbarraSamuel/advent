from collections.abc import Sequence
from dataclasses import dataclass
from typing import Self, override

from advent_utils import AdventSolution


@dataclass
class Game:
    r: int
    g: int
    b: int

    @staticmethod
    def from_card(card: str):
        self = Game(0, 0, 0)
        rgb = card.split(", ")
        for color in rgb:
            tp = color.split(" ")
            if tp[1] == "red":
                self.r += int(tp[0])
            if tp[1] == "green":
                self.g += int(tp[0])
            if tp[1] == "blue":
                self.b += int(tp[0])

        return self

    def __contains__(self, other: Self) -> bool:
        return self.r >= other.r and self.g >= other.g and self.b >= other.b


MAX_GAME = Game(12, 13, 14)


class Solution(AdventSolution):
    @staticmethod
    @override
    def part_1(lines: Sequence[str]) -> str:
        total = 0

        def calc_line(idx: int, total: int) -> None:
            try:
                for card in lines[idx].split("; "):
                    if Game.from_card(card) not in MAX_GAME:
                        return
                total += idx + 1
            except Exception:
                pass

        for i in range(len(lines)):
            calc_line(i, total)

        return str(total)

    @staticmethod
    @override
    def part_2(lines: Sequence[str]) -> str:
        return ""
