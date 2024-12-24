from max.graph import Graph, Type, TensorType, ops
from max.tensor import Tensor, TensorShape

alias TARGET = "XMAS".as_bytes()


struct Solution:
    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        """Part 1 solution.

        ```mojo
        from advent_utils import test
        from days.day03 import Solution

        test[Solution, file="tests/2024/day04.txt", part=1, expected=18]()
        ```
        """
        tot = 0
        lines = data.splitlines()

        # Vertical
        for line in lines:
            n = line[].find("XMAS")
            r = line[].rfind("SAMX")
            tot += n * (n > -1) + 0 * (n == -1)
            tot += r * (r > -1) + 0 * (r == -1)

        # Horizontal
        for col in range(len(lines[0])):
            for row in range(len(lines)):
                if len(lines) - row < 4:
                    break
                if (
                        lines[row][col] == "X"
                        and lines[row + 1][col] == "M"
                        and lines[row + 2][col] == "A"
                        and lines[row + 3][col] == "S"
                    )
                    or (
                        lines[row][col] == "S"
                        and lines[row + 1][col] == "A"
                        and lines[row + 2][col] == "M"
                        and lines[row + 3][col] == "X"
                    ):
                    tot += 1

        # how many diags?
        diags = len(lines) + len(lines[0]) - 1 # repeated at corner

        # Diagonal 45?
        # Diagonal 135?
        # ...

        # TODO: Iterate on all 8 positibilites.
        # Down to Up
        # Up to Down
        # Left to Right
        # Right to Left
        # 45 UP
        # 45 DOWN
        # 135 UP
        # 135 DOWN
        # This could be done on 8 threads.
        return tot

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        from days.day03 import Solution

        test[Solution, file="tests/2024/day032.txt", part=2, expected=0]()
        ```
        """
        tot = 0
        return tot
