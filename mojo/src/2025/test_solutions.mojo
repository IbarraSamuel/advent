from advent_utils import test, YEAR
from testing import TestSuite
import days

comptime FILES_LOCATION = "tests/" + YEAR


fn test_day01_part1() raises:
    test[days.day01.Solution, 1, FILES_LOCATION + "/day01.txt", expected=11]()


fn test_day01_part2() raises:
    test[days.day01.Solution, 2, FILES_LOCATION + "/day01.txt", expected=31]()


fn test_day02_part1() raises:
    test[days.day02.Solution, 1, FILES_LOCATION + "/day02.txt", expected=2]()


fn test_day02_part2() raises:
    test[days.day02.Solution, 2, FILES_LOCATION + "/day02.txt", expected=4]()
    test[days.day02.Solution, 2, FILES_LOCATION + "/day022.txt", expected=28]()


fn test_day03_part1() raises:
    test[days.day03.Solution, 1, FILES_LOCATION + "/day03.txt", expected=161]()


fn test_day03_part2() raises:
    test[days.day03.Solution, 2, FILES_LOCATION + "/day032.txt", expected=48]()


fn test_day04_part1() raises:
    test[days.day04.Solution, 1, FILES_LOCATION + "/day04.txt", expected=18]()
    test[days.day04.Solution, 1, FILES_LOCATION + "/day044.txt", expected=4]()


fn test_day04_part2() raises:
    test[days.day04.Solution, 2, FILES_LOCATION + "/day04.txt", expected=9]()


fn test_day05_part1() raises:
    test[days.day05.Solution, 1, FILES_LOCATION + "/day05.txt", expected=143]()


fn test_day05_part2() raises:
    test[days.day05.Solution, 2, FILES_LOCATION + "/day05.txt", expected=123]()


fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

    # TestSuite.discover_tests[
    #     (
    #         test[days.day01.Solution, 1, "tests/2024/day01.txt", expected=11],
    #         test[days.day01.Solution, 2, "tests/2024/day01.txt", expected=31],
    #         test[days.day02.Solution, 1, "tests/2024/day02.txt", expected=2],
    #         test[days.day02.Solution, 2, "tests/2024/day02.txt", expected=4],
    #         test[days.day02.Solution, 2, "tests/2024/day022.txt", expected=28],
    #         test[days.day03.Solution, 1, "tests/2024/day03.txt", expected=161],
    #         test[days.day03.Solution, 2, "tests/2024/day032.txt", expected=48],
    #         test[days.day04.Solution, 1, "tests/2024/day04.txt", expected=18],
    #         test[days.day04.Solution, 1, "tests/2024/day044.txt", expected=4],
    #         test[days.day04.Solution, 2, "tests/2024/day04.txt", expected=9],
    #         test[days.day05.Solution, 1, "tests/2024/day05.txt", expected=143],
    #         test[days.day05.Solution, 2, "tests/2024/day05.txt", expected=123],
    #     ),
    # ]().run()
