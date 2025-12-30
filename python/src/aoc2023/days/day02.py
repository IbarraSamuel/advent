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
        """Create a game from a card.

        Returns
        -------
        a new game object.

        """
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

        return self

    @staticmethod
    def max_from_cards(cards: str) -> Game:
        """Create a game from cards.

        Returns
        -------
        A new game object,

        """
        self = Game(0, 0, 0)
        for card in cards.split("; "):
            self = self.max(Game.from_card(card))
        return self

    def __contains__(self, other: Self) -> bool:
        """Check if self contains other.

        Returns
        -------
        If the game contains another game inside.

        """
        return self.r >= other.r and self.g >= other.g and self.b >= other.b

    def max(self, other: Self) -> Game:
        """Return the max of self and other.

        Returns
        -------
        The max game.

        """
        return Game(max(self.r, other.r), max(self.g, other.g), max(self.b, other.b))

    def __add__(self, other: Self) -> Game:
        """Add two games.

        Returns
        -------
        The concatenated game

        """
        return Game(self.r + other.r, self.g + other.g, self.b + other.b)

    def product(self) -> int:
        """Return the product of each color.

        Returns
        -------
        The multiplication of all fields

        """
        return self.r * self.g * self.b


MAX_GAME = Game(12, 13, 14)


class Solution:
    """Solution for the second day."""

    @staticmethod
    def part_1(lines: Sequence[str]) -> int:
        """Return the solution for day 1.

        Returns
        -------
        The part 1 solution.

        """
        return sum(
            idx + 1
            for idx, line in enumerate(lines)
            if Game.max_from_cards(line.split(": ")[1]) in MAX_GAME
        )

    @staticmethod
    def part_2(lines: Sequence[str]) -> int:
        """Return the solution for day 2.

        Returns
        -------
        The part 2 solution.

        """
        return sum(Game.max_from_cards(line.split(": ")[1]).product() for line in lines)
