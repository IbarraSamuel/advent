from algorithm.functional import vectorize
from collections import Set
from utils import IndexList
from advent_utils import ListSolution


@value
struct Point(KeyElement):
    var x: Int
    var y: Int

    fn __hash__(self) -> UInt:
        return self.x * 1000000 + self.y

    fn __eq__(self, other: Self) -> Bool:
        return self.x == other.x and self.y == other.y

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


fn parse_number[dir: Int](s: String, pos: Int) -> Tuple[String, Int]:
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


fn check_window(
    point: Point,
    input: List[String],
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
            if input[y][x].isdigit():
                to_parse, first_x = parse_number[0](input[y], x)
                var current_point = Point(first_x, y)
                if current_point not in results:
                    results.add(current_point)
                    try:
                        total += atol(to_parse)
                    except:
                        pass


fn check_window[
    number_limit: Int
](point: Point, input: List[String], mut results: Set[Point], mut total: Int):
    var min_x = max(point.x - 1, 0)
    var max_x = min(point.x + 1, len(input[0]) - 1)
    var min_y = max(point.y - 1, 0)
    var max_y = min(point.y + 1, len(input) - 1)
    var first_x: Int
    var to_parse: String
    var old_results = results
    var local_result: IndexList[2] = (0, 0)
    var local_count = 0

    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if input[y][x].isdigit():
                to_parse, first_x = parse_number[0](input[y], x)
                var current_point = Point(first_x, y)
                if current_point not in results:
                    local_count += 1
                    if local_count > number_limit:
                        results = old_results
                        return
                    results.add(current_point)
                    try:
                        local_result[local_count - 1] = atol(to_parse)
                    except:
                        pass

    if local_count < number_limit:
        results = old_results
        return

    total += local_result[0] * local_result[1]


struct Solution(ListSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(input: List[String]) -> UInt32:
        var points = List[Point]()
        var x_len = len(input[0])
        var y_len = len(input)

        @parameter
        fn check_line[v: Int](y: Int):
            @parameter
            fn check_position[v: Int](x: Int):
                if input[y][x] != "." and not input[y][x].isdigit():
                    points.append(Point(x, y))

            vectorize[check_position, 1](x_len)

        vectorize[check_line, 1](y_len)

        var total = 0
        var results = Set[Point]()
        for point in points:
            check_window(point, input, results, total)

        return total

    @staticmethod
    fn part_2(input: List[String]) -> UInt32:
        var points = List[Point]()
        var x_len = len(input[0])
        var y_len = len(input)

        @parameter
        fn check_line[v: Int](y: Int):
            @parameter
            fn check_position[v: Int](x: Int):
                if input[y][x] == "*":
                    points.append(Point(x, y))

            vectorize[check_position, 1](x_len)

        vectorize[check_line, 1](y_len)

        var total = 0
        var results = Set[Point]()
        for point in points:
            check_window[2](point, input, results, total)

        return total
