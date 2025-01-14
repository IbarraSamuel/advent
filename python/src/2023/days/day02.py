"""Day 2: Card Game."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Self

if TYPE_CHECKING:
    from collections.abc import Sequence


@dataclass
class Game:
    """Represents a game."""

    r: int
    g: int
    b: int

    @staticmethod
    def from_card(card: str) -> Game:
        """Create a game from a card."""
        self = Game(0, 0, 0)
        rgb = card.split(", ")
        for color in rgb:
            v, clr = color.split(" ")
            if clr.endswith("d"):
                self.r += int(v)
            elif clr.endswith("n"):
                self.g += int(v)
            else:
                self.b += int(v)

        return self  # noqa: DOC201

    @staticmethod
    def max_from_cards(cards: str) -> Game:
        """Create a game from cards."""
        self = Game(0, 0, 0)
        for card in cards.split("; "):
            self = self.max(Game.from_card(card))
        return self  # noqa: DOC201

    def __contains__(self, other: Self) -> bool:
        """Check if self contains other."""
        return self.r >= other.r and self.g >= other.g and self.b >= other.b  # noqa: DOC201

    def max(self, other: Self) -> Game:
        """Return the max of self and other."""
        return Game(max(self.r, other.r), max(self.g, other.g), max(self.b, other.b))  # noqa: DOC201

    def __add__(self, other: Self) -> Game:
        """Add two games."""
        return Game(self.r + other.r, self.g + other.g, self.b + other.b)  # noqa: DOC201

    def product(self) -> int:
        """Return the product of each color."""
        return self.r * self.g * self.b  # noqa: DOC201


MAX_GAME = Game(12, 13, 14)


class Solution:
    """Solution for the second day."""

    @staticmethod
    def part_1(lines: Sequence[str]) -> int:
        """Return the solution for day 1."""
        return sum(  # noqa: DOC201
            idx + 1
            for idx, line in enumerate(lines)
            if Game.max_from_cards(line.split(": ")[1]) in MAX_GAME
        )

    @staticmethod
    def part_2(lines: Sequence[str]) -> int:
        """Return the solution for day 2."""
        return sum(Game.max_from_cards(line.split(": ")[1]).product() for line in lines)  # noqa: DOC201
