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
        import days

        test[days.day04.Solution, file="tests/2024/day04.txt", part=1, expected=18]()
        test[days.day04.Solution, file="tests/2024/day044.txt", part=1, expected=4]()
        ```
        """
        tot = 0
        lines = data.splitlines()

        # Horizontal
        for y in range(len(lines)):
            y0, yy0 = 0, 0
            while True:
                n = lines[y].find("XMAS", y0)
                if n > -1:
                   print("Found at (", n, ",", y, ") with direction Horiz ", "L" if lines[y][n] == "S" else "R", sep="")
                   y0 = n + 3
                   tot += 1
                r = lines[y].find("SAMX", yy0)
                if r > -1:
                   print("Found at (", r, ",", y, ") with direction Horiz ", "L" if lines[y][r] == "S" else "R", sep="")
                   yy0 = r + 3
                   tot += 1

                if n == -1 and r == -1:
                    break

        # Vertical
        for col in range(len(lines[0])):
            for row in range(len(lines)):
                if (len(lines) - row) < 4:
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
                    print("Found at (", col, ",", row, ") with direction Vertial ", "U" if lines[row][col] == "S" else "D", sep="")
                    tot += 1

        # how many diags?
        diags = len(lines) + len(lines[0]) - 1 # repeated at corner
        ymax = len(lines)
        xmax = len(lines[0])

        for p in range(diags):
            # 45 deg
            x, y = 0 if p < ymax else p - ymax + 1, p if p < ymax else ymax -1
            while y >= 3 and x < xmax - 3:
                if (
                        lines[y][x] == "X"
                        and lines[y- 1][x+1] == "M"
                        and lines[y- 2][x+2] == "A"
                        and lines[y- 3][x+3] == "S"
                    )
                    or (
                        lines[y][x] == "S"
                        and lines[y- 1][x+1] == "A"
                        and lines[y- 2][x+2] == "M"
                        and lines[y- 3][x+3] == "X"
                    ):
                    print("Found at (", x, ",", y, ") with direction 45", "D" if lines[y][x] == "S" else "U", sep="")
                    tot += 1

                x += 1
                y -= 1

            
            # 135 deg
            x, y = p, 0
            x, y = p if p < xmax else xmax - 1, 0 if p < xmax else p - xmax + 1
            while x >= 3 and y < ymax - 3:
                if (
                        lines[y][x] == "X"
                        and lines[y+ 1][x-1] == "M"
                        and lines[y+ 2][x-2] == "A"
                        and lines[y+ 3][x-3] == "S"
                    )
                    or (
                        lines[y][x] == "S"
                        and lines[y+ 1][x-1] == "A"
                        and lines[y+ 2][x-2] == "M"
                        and lines[y+ 3][x-3] == "X"
                    ):
                    print("Found at (", x, ",", y, ") with direction 135", "D" if lines[y][x] == "S" else "U", sep="")
                    tot += 1

                x -= 1
                y += 1

        return tot

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        import days

        test[days.day04.Solution, file="tests/2024/day032.txt", part=2, expected=0]()
        ```
        """
        tot = 0
        return tot
