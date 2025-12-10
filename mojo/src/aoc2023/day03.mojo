from algorithm.functional import vectorize
from collections import Set
from utils import IndexList
from hashlib.hasher import Hasher
from advent_utils import AdventSolution


@fieldwise_init
struct Point(Copyable, KeyElement):
    var x: Int
    var y: Int

    fn __hash__(self, mut hasher: Some[Hasher]):
        hasher.update(self.x)
        hasher.update(self.y)

    fn __eq__(self, other: Self) -> Bool:
        return self.x == other.x and self.y == other.y

    fn copy(self) -> Self:
        return Point(self.x, self.y)


fn parse_number[dir: Int](s: StringSlice, pos: Int) -> Tuple[String, Int]:
    var current = s[pos]
    var left: String = ""
    var lpos: Int = pos
    var right: String = ""

    if pos > 0 and s[pos - 1].isdigit() and dir <= 0:
        left, lpos = parse_number[-1](s, pos - 1)

    if pos < len(s) - 1 and s[pos + 1].isdigit() and dir >= 0:
        right, _ = parse_number[+1](s, pos + 1)
    current = left + current + right
    return current, lpos


fn check_window[
    origin: Origin
](
    point: Point,
    input: List[StringSlice[origin]],
    mut results: Set[Point],
    mut total: Int,
):
    var min_x = max(point.x - 1, 0)
    var max_x = min(point.x + 1, len(input[0]) - 1)
    var min_y = max(point.y - 1, 0)
    var max_y = min(point.y + 1, len(input) - 1)
    var first_x: Int
    var to_parse: String

    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if String(input[y][x]).isdigit():
                to_parse, first_x = parse_number[0](input[y], x)
                var current_point = Point(first_x, y)
                if current_point not in results:
                    results.add(current_point)
                    try:
                        total += atol(to_parse)
                    except:
                        pass


fn check_window[
    origin: Origin, //, number_limit: Int
](
    point: Point,
    input: List[StringSlice[origin]],
    mut results: Set[Point],
    mut total: Int,
):
    var min_x = max(point.x - 1, 0)
    var max_x = min(point.x + 1, len(input[0]) - 1)
    var min_y = max(point.y - 1, 0)
    var max_y = min(point.y + 1, len(input) - 1)
    var first_x: Int
    var to_parse: String
    var old_results = results.copy()
    var local_result: IndexList[2] = (0, 0)
    var local_count = 0

    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if String(input[y][x]).isdigit():
                to_parse, first_x = parse_number[0](input[y], x)
                var current_point = Point(first_x, y)
                if current_point not in results:
                    local_count += 1
                    if local_count > number_limit:
                        results = old_results^
                        return
                    results.add(current_point)
                    try:
                        local_result[local_count - 1] = atol(to_parse)
                    except:
                        pass

    if local_count < number_limit:
        results = old_results^
        return

    total += local_result[0] * local_result[1]


struct Solution(AdventSolution):
    comptime T = UInt32

    @staticmethod
    fn part_1(data: StringSlice) -> UInt32:
        var input = data.splitlines()
        var x_len = len(input[0])
        var y_len = len(input)
        var points = List[Point](length=x_len, fill=Point(0, 0))

        fn check_line[
            v: Int
        ](y: Int) unified {read input, read x_len, mut points}:
            fn check_position[
                v: Int
            ](x: Int) unified {mut points, read y, read input}:
                if (
                    input[y][x] != StaticString(".")
                    and not String(input[y][x]).isdigit()
                ):
                    points[x] = Point(x, y)

            vectorize[1](x_len, check_position)

        vectorize[1](y_len, check_line)

        var total = 0
        var results = Set[Point]()
        for point in points:
            check_window(point, input, results, total)

        return total

    @staticmethod
    fn part_2(data: StringSlice) -> UInt32:
        var input = data.splitlines()
        var x_len = len(input[0])
        var y_len = len(input)
        var points = List[Point](length=x_len, fill=Point(0, 0))

        fn check_line[
            v: Int
        ](y: Int) unified {read input, read x_len, mut points}:
            fn check_position_[
                v: Int
            ](x: Int) unified {read y, read input, mut points}:
                if input[y][x] == "*":
                    points[x] = Point(x, y)

            vectorize[1](x_len, check_position_)

        vectorize[1](y_len, check_line)

        var total = 0
        var results = Set[Point]()
        for point in points:
            check_window[2](point, input, results, total)

        return total
