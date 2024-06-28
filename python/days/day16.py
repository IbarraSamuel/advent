with open("../inputs/day16.txt") as file:
    grid = file.read().splitlines()


def calc_energized(grid: list[str], start: tuple[int, int, int, int]) -> int:
    # (row, col, movement row, movement col)
    queue = [start]
    seen: set[tuple[int, int, int, int]] = set()

    while queue:
        row, col, drow, dcol = queue.pop(0)
        row += drow
        col += dcol

        if row < 0 or row >= len(grid) or col < 0 or col >= len(grid[0]):
            continue

        new_pos = grid[row][col]

        if (
            new_pos == "."
            or (new_pos == "-" and dcol != 0)
            or (new_pos == "|" and drow != 0)
        ):
            queue.append((row, col, drow, dcol))
            seen.add((row, col, drow, dcol))

        elif new_pos == "\\":
            drow, dcol = dcol, drow
            if (row, col, drow, dcol) not in seen:
                queue.append((row, col, drow, dcol))
                seen.add((row, col, drow, dcol))

        elif new_pos == "/":
            drow, dcol = -dcol, -drow
            if (row, col, drow, dcol) not in seen:
                queue.append((row, col, drow, dcol))
                seen.add((row, col, drow, dcol))

        else:
            for dr, dc in [(1, 0), (-1, 0)] if new_pos == "|" else [(0, 1), (0, -1)]:
                if (row, col, dr, dc) not in seen:
                    queue.append((row, col, dr, dc))
                    seen.add((row, col, dr, dc))

    visited = {(row, col) for (row, col, _, _) in seen}

    return len(visited)


# row -1 because its like you start outside the grid
solution1 = calc_energized(grid, (0, -1, 0, 1))

solution2 = 0
for row in range(len(grid)):
    solution2 = max(
        solution2,
        calc_energized(grid, (row, -1, 0, 1)),
        calc_energized(grid, (row, len(grid), 0, -1)),
    )

for col in range(len(grid[0])):
    solution2 = max(
        solution2,
        calc_energized(grid, (-1, col, 1, 0)),
        calc_energized(grid, (len(grid), col, -1, 0)),
    )

