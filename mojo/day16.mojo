from algorithm.reduction import max, any_true
from algorithm.functional import vectorize
from builtin.dtype import DType
from builtin.int_literal import IntLiteral
alias Position = SIMD[DType.int32, 4]


fn is_in(value: Position, collection: DynamicVector[Position]) -> Bool:
    for i in range(0, collection.size):
        if value == collection[i]:
            return True
    return False


fn calc_energized(grid: DynamicVector[String], start: Position) -> Int:
    # (row, col, movement row, movement col)
    var queue = DynamicVector[Position]()
    queue.append(start)
    var seen = DynamicVector[Position]()


    while queue.size > 0:
        let v = queue.pop_back()
        var row: Int32
        var col: Int32
        var drow: Int32
        var dcol: Int32

        row, col, drow, dcol = v[0], v[1], v[2], v[3]
        row += drow
        col += dcol

        if row < 0 or row >= len(grid) or col < 0 or col >= len(grid[0]):
            continue

        let new_pos = grid[row.value][col.value]

        if (
            new_pos == "."
            or (new_pos == "-" and dcol != 0)
            or (new_pos == "|" and drow != 0)
        ):
            queue.append(SIMD[DType.int32, 4](row, col, drow, dcol))
            if not is_in(SIMD[DType.int32, 4](row, col, drow, dcol), seen):
                seen.append(SIMD[DType.int32, 4](row, col, drow, dcol))

        elif new_pos == "\\":
            drow, dcol = dcol, drow
            if not is_in(SIMD[DType.int32, 4](row, col, drow, dcol), seen):
                queue.append(SIMD[DType.int32, 4](row, col, drow, dcol))
                seen.append(SIMD[DType.int32, 4](row, col, drow, dcol))

        elif new_pos == "/":
            drow, dcol = -dcol, -drow
            if not is_in(SIMD[DType.int32, 4](row, col, drow, dcol), seen):
                queue.append(SIMD[DType.int32, 4](row, col, drow, dcol))
                seen.append(SIMD[DType.int32, 4](row, col, drow, dcol))

        else:
            let dirlist = [(1, 0), (-1, 0)] if new_pos == "|" else [(0, 1), (0, -1)]
            let dr1 = dirlist.get[0, Tuple[Int, Int]]().get[0, Int]()
            let dc1 = dirlist.get[0, Tuple[Int, Int]]().get[1, Int]()
            let dr2 = dirlist.get[1, Tuple[Int, Int]]().get[0, Int]()
            let dc2 = dirlist.get[1, Tuple[Int, Int]]().get[1, Int]()

            if not is_in(SIMD[DType.int32, 4](row, col, dr1, dc1), seen):
                queue.append(SIMD[DType.int32, 4](row, col, dr1, dc1))
                seen.append(SIMD[DType.int32, 4](row, col, dr1, dc1))
            
            if not is_in(SIMD[DType.int32, 4](row, col, dr2, dc2), seen):
                queue.append(SIMD[DType.int32, 4](row, col, dr2, dc2))
                seen.append(SIMD[DType.int32, 4](row, col, dr2, dc2))


    var visited = DynamicVector[SIMD[DType.int32, 2]]()
    for i in range(0, seen.size):
        let x = seen[i][0]
        let y = seen[i][1]
        for j in range(0, len(visited)):
            if SIMD[DType.int32, 2](x, y) == visited[j]:
                break
        else:
            visited.append(SIMD[DType.int32, 2](x, y))

    return len(visited)

fn max_of_three(a: Int, b: Int, c: Int) -> Int:
    var max_value = a  # Assume a is the maximum initially

    # Compare b with max_value
    if b > max_value:
        max_value = b

    # Compare c with max_value
    if c > max_value:
        max_value = c

    return max_value

fn day16(input_value: DynamicVector[String]) -> Int:

    # row -1 because its like you start outside the grid
    let solution1 = calc_energized(input_value, SIMD[DType.int32, 4](0, -1, 0, 1))
    print("Solution 1", solution1)

    var solution2 = 0
    for row in range(len(input_value)):
        solution2 = math.max(math.max(calc_energized(input_value, SIMD[DType.int32, 4](row, -1, 0, 1)), calc_energized(input_value, SIMD[DType.int32, 4](row, len(input_value), 0, -1))), solution2)

    for col in range(len(input_value[0])):
        solution2 = math.max(solution2, math.max(calc_energized(input_value, SIMD[DType.int32, 4](-1, col, 1, 0)) , calc_energized(input_value, SIMD[DType.int32, 4](len(input_value), col, -1, 0))))


    print("Solution 2", solution2)
    return solution1

