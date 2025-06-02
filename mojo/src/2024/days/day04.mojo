from advent_utils import AdventSolution


@fieldwise_init
struct Dir(EqualityComparable, Movable, Copyable):
    alias error = Dir(0)
    alias up = Dir(1)
    alias down = Dir(2)
    alias left = Dir(3)
    alias right = Dir(4)
    alias upleft = Dir(5)
    alias downleft = Dir(6)
    alias upright = Dir(7)
    alias downright = Dir(8)
    var v: Int

    fn __init__(pos: (Int, Int), rel_pos: (Int, Int)) -> Self:
        xi, yi = rel_pos
        x, y = pos
        if xi - x == -1 and yi - y == -1:
            return Self.upleft
        elif xi - x == 0 and yi - y == -1:
            return Self.up
        elif xi - x == 1 and yi - y == -1:
            return Self.upright
        elif xi - x == 1 and yi - y == 0:
            return Self.right
        elif xi - x == 1 and yi - y == 1:
            return Self.downright
        elif xi - x == 0 and yi - y == 1:
            return Self.down
        elif xi - x == -1 and yi - y == 1:
            return Self.downleft
        elif xi - x == -1 and yi - y == 0:
            return Self.left
        else:
            return Self.error

    fn delta(self) -> (Int, Int):
        yi = (
            -1 if self
            in [Self.upleft, Self.upright, Self.up] else 1 if self
            in [Self.down, Self.downleft, Self.downright] else 0
        )
        xi = (
            1 if self
            in [Self.upright, Self.right, Self.downright] else -1 if self
            in [Self.upleft, Self.left, Self.downleft] else 0
        )
        return (xi, yi)

    fn __eq__(self, other: Self) -> Bool:
        return self.v == other.v

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


struct Solution(AdventSolution):
    alias T = Int32

    @staticmethod
    fn part_1[o: ImmutableOrigin](data: StringSlice[o]) -> Self.T:
        """Part 1 solution.

        ```mojo
        from advent_utils import test
        import days

        test[days.day04.Solution, file="tests/2024/day04.txt", part=1, expected=18]()
        test[days.day04.Solution, file="tests/2024/day044.txt", part=1, expected=4]()
        ```
        """
        tot = 0
        ls = data.splitlines()
        xmax, ymax = len(ls[0]), len(ls)

        for y in range(ymax):
            last = 0
            while True:
                x = ls[y].find("X", last)
                if x == -1:
                    print(x, "--level x finished")
                    break

                print("[START] an x in pos (", x, ",", y, ")")
                # We will start always from the top left corner in a clockwise manner.
                last = x + 1
                print(
                    "We will go from (",
                    max(0, x - 1),
                    max(0, y - 1),
                    ") to (",
                    min(xmax - 1, x + 1),
                    min(ymax - 1, y + 1),
                    ") inclusive",
                )

                for xi in range(max(0, x - 1), min(xmax - 1, x + 1) + 1):
                    for yi in range(max(0, y - 1), min(ymax - 1, y + 1) + 1):
                        if ls[yi][xi] != "M":
                            print(
                                "[--] (",
                                xi,
                                ",",
                                yi,
                                ") no m found. end --",
                            )
                            continue
                        dir = Dir((x, y), (xi, yi))
                        dx, dy = dir.delta()
                        print(
                            "[--]an m in pos (",
                            xi,
                            ",",
                            yi,
                            ")",
                            " and delta: (",
                            dx,
                            ",",
                            dy,
                            ")",
                        )
                        xii, yii = xi + dx, yi + dy
                        if (
                            0 > xii
                            or xii >= xmax
                            or 0 > yii
                            or yii >= ymax
                            or ls[yii][xii] != "A"
                        ):
                            print(
                                "[--][--] (",
                                xii,
                                ",",
                                yii,
                                ") no a found. end --",
                            )
                            continue

                        print("[--][--]an a in pos (", xii, ",", yii, ")")
                        xii, yii = xii + dx, yii + dy
                        if (
                            0 > xii
                            or xii >= xmax
                            or 0 > yii
                            or yii >= ymax
                            or ls[yii][xii] != "S"
                        ):
                            print(
                                "[--][--][--] (",
                                xii,
                                ",",
                                yii,
                                ") no s found. end --",
                            )
                            continue

                        print(
                            "[--][--][--]an s in pos (",
                            xii,
                            ",",
                            yii,
                            ")",
                            " ->> +1!!",
                        )
                        tot += 1
            print(
                y,
                (
                    ">>>>>>>>>>>><<<<<>>>>><<<>>> row y -> No more results for"
                    " it -- "
                ),
                "current count:",
                tot,
                "\n",
            )

            # var res = [Dir(y) for y in ry for x in rx]

            # var positions = [(x, y) for x in rx for y in ry]

        return tot

    @staticmethod
    fn part_2[o: ImmutableOrigin](data: StringSlice[o]) -> Self.T:
        """Part 2 solution.

        ```mojo
        from advent_utils import test
        import days

        test[days.day04.Solution, file="tests/2024/day032.txt", part=2, expected=0]()
        ```
        """
        tot = 0
        return tot
