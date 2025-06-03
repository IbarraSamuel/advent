from advent_utils import test
import days


fn test_day01() raises:
    test[days.day01.Solution, 1, "tests/2024/day01.txt", expected=11]()
    test[days.day01.Solution, 2, "tests/2024/day01.txt", expected=31]()


fn test_day02() raises:
    test[days.day02.Solution, 1, "tests/2024/day02.txt", expected=2]()
    test[days.day02.Solution, 2, "tests/2024/day02.txt", expected=4]()
    test[days.day02.Solution, 2, "tests/2024/day022.txt", expected=28]()


fn test_day03() raises:
    test[days.day03.Solution, 1, "tests/2024/day03.txt", expected=161]()
    test[days.day03.Solution, 2, "tests/2024/day032.txt", expected=48]()


fn test_day04() raises:
    test[days.day04.Solution, 1, "tests/2024/day04.txt", expected=18]()
    test[days.day04.Solution, 1, "tests/2024/day044.txt", expected=4]()
    test[days.day04.Solution, 2, "tests/2024/day04.txt", expected=9]()


fn test_day5() raises:
    test[days.day05.Solution, 1, "tests/2024/day05.txt", expected=143]()
    test[days.day05.Solution, 2, "tests/2024/day05.txt", expected=0]()
