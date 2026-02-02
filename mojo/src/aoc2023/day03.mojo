from algorithm.functional import vectorize
from collections import Set
from utils import IndexList
from hashlib.hasher import Hasher
from advent_utils import AdventSolution
import os


struct AstrInfo(Copyable, Equatable):
    var pos: Tuple[Int, Int]
    var value: Int
    var count: Int

    fn __init__(out self, x: Int, y: Int):
        self.pos = (x, y)
        self.value = 0
        self.count = 1

    fn __eq__(self, other: Self) -> Bool:
        return self.pos == other.pos


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    fn part_1(data: StringSlice) -> Int:
        var input = data.splitlines()
        var tot = 0

        for y, line in enumerate(input):
            var max_x = len(line) - 1
            x = 0
            while x < max_x:
                if not line[byte=x].is_ascii_digit():
                    x += 1
                    continue

                has_asterisc = False

                var min_y = max(0, y - 1)
                var max_y = min(len(input) - 1, y + 1)
                var min_x = max(0, x - 1)

                if x - 1 >= min_x:
                    for yi in range(min_y, max_y + 1):
                        if input[yi][byte = x - 1] != StringSlice("."):
                            has_asterisc = True
                            break

                var val: Int
                try:
                    val = Int(line[byte=x])
                except:
                    os.abort("Invalid input for str to int conversion")

                if not has_asterisc and (
                    (y != min_y and input[min_y][byte=x] != StringSlice("."))
                    or (y != max_y and input[max_y][byte=x] != StringSlice("."))
                ):
                    has_asterisc = True

                while (
                    x + 1 < len(line)
                    and input[y][byte = x + 1].is_ascii_digit()
                ):
                    x += 1
                    try:
                        val = val * 10 + Int(input[y][byte=x])
                    except:
                        os.abort(
                            "invalid input for str to int conversion on"
                            " while loop"
                        )
                    if not has_asterisc and (
                        (
                            y != min_y
                            and input[min_y][byte=x] != StringSlice(".")
                        )
                        or (
                            y != max_y
                            and input[max_y][byte=x] != StringSlice(".")
                        )
                    ):
                        has_asterisc = True

                if not has_asterisc and x + 1 < len(line):
                    for yi in range(min_y, max_y + 1):
                        if input[yi][byte = x + 1] != StringSlice("."):
                            has_asterisc = True
                            break

                if has_asterisc:
                    tot += val

                x += 2

        return tot

    @staticmethod
    fn part_2(data: StringSlice) -> Int:
        var input = data.splitlines()
        var astr = List[AstrInfo](capacity=1000)
        var tot = 0

        for y, line in enumerate(input):
            var max_x = len(line) - 1
            x = 0
            while x < max_x:
                if not line[byte=x].is_ascii_digit():
                    x += 1
                    continue

                var asterisc = Optional[AstrInfo]()

                var min_y = max(0, y - 1)
                var max_y = min(len(input) - 1, y + 1)
                var min_x = max(0, x - 1)

                if x - 1 >= min_x:
                    for yi in range(min_y, max_y + 1):
                        if input[yi][byte = x - 1] == "*":
                            asterisc = AstrInfo(x - 1, yi)
                            break

                var val: Int
                try:
                    val = Int(line[byte=x])
                except:
                    os.abort("Invalid input for str to int conversion")

                if not asterisc and y != min_y and input[min_y][byte=x] == "*":
                    asterisc = AstrInfo(x, min_y)

                if not asterisc and y != max_y and input[max_y][byte=x] == "*":
                    asterisc = AstrInfo(x, max_y)

                while (
                    x + 1 < len(line)
                    and input[y][byte = x + 1].is_ascii_digit()
                ):
                    x += 1
                    try:
                        val = val * 10 + Int(input[y][byte=x])
                    except:
                        os.abort(
                            "invalid input for str to int conversion on"
                            " while loop"
                        )
                    if (
                        not asterisc
                        and y != min_y
                        and input[min_y][byte=x] == "*"
                    ):
                        asterisc = AstrInfo(x, min_y)

                    if (
                        not asterisc
                        and y != max_y
                        and input[max_y][byte=x] == "*"
                    ):
                        asterisc = AstrInfo(x, max_y)

                if not asterisc and x + 1 < len(line):
                    for yi in range(min_y, max_y + 1):
                        if input[yi][byte = x + 1] == "*":
                            asterisc = AstrInfo(x + 1, yi)
                            break

                if asterisc:
                    for ref a in astr:
                        if a == asterisc.unsafe_value():
                            a.count += 1
                            if a.count == 2:
                                a.value *= val
                                tot += a.value
                            if a.count == 3:
                                tot -= a.value
                            break
                    else:
                        var a = asterisc.take()
                        a.value = val
                        astr.append(a^)

                x += 2

        return tot
