from advent_utils import read_input, run, test_solution
import year_2023


fn test_day01() raises:
    test_solution[
        year_2023.day01.Solution,
        ("../tests/day1_1.txt", 142),
        ("../tests/day1_2.txt", 281),
    ]()


fn test_day02() raises:
    test_solution[
        year_2023.day02.Solution,
        ("../tests/day2_1.txt", (8, 2286)),
    ]()


fn test_day03() raises:
    test_solution[
        year_2023.day03.Solution,
        ("../tests/day3_1.txt", (4361, 467835)),
    ]()


fn test_day04() raises:
    test_solution[
        year_2023.day04.Solution,
        ("../tests/day4_1.txt", (13, 30)),
    ]()


fn test_day05() raises:
    test_solution[
        year_2023.day05.Solution,
        ("../tests/day5_1.txt", (35, 46)),
    ]()


fn test_day06() raises:
    test_solution[
        year_2023.day06.Solution,
        ("../tests/day6.txt", (288, 71503)),
    ]()


fn test_day07() raises:
    test_solution[
        year_2023.day07.Solution,
        ("../tests/day7.txt", (6440, 5905)),
    ]()


fn test_day08() raises:
    test_solution[
        year_2023.day08.Solution,
        ("../tests/day8_1.txt", 2),
        ("../tests/day8_2.txt", 6),
    ]()


fn test_day09() raises:
    test_solution[
        year_2023.day09.Solution,
        ("../tests/day9.txt", (114, 2)),
    ]()


fn test_day10() raises:
    test_solution[
        year_2023.day10.Solution,
        ("../tests/day10.txt", (8, -1)),
        ("../tests/day10_2.txt", (-1, 4)),
        ("../tests/day10_3.txt", (-1, 8)),
        ("../tests/day10_4.txt", (-1, 10)),
    ]()


fn test_day11() raises:
    test_solution[
        year_2023.day11.Solution,
        ("../tests/day11.txt", (374, 82000210)),
    ]()


fn test_day12() raises:
    test_solution[
        year_2023.day12.Solution,
        ("../tests/day12.txt", (21, 525152)),
    ]()


fn test_day13() raises:
    test_solution[
        year_2023.day13.Solution,
        ("../tests/day13.txt", (405, 400)),
    ]()


fn test_day14() raises:
    test_solution[
        year_2023.day14.Solution,
        ("../tests/day14.txt", (136, 64)),
    ]()


fn test_day15() raises:
    test_solution[
        year_2023.day15.Solution,
        ("../tests/day15.txt", (1320, 145)),
    ]()


fn test_day16() raises:
    test_solution[
        year_2023.day16.Solution,
        ("../tests/day16.txt", (46, 51)),
    ]()


# fn test_day17() raises:
#     test_solution[
#         year_2023.day17.Solution,
#         ("../tests/day17.txt", (102, -1)),
#    ]()
