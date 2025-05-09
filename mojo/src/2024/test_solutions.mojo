from advent_utils import test
from days.day01 import Solution


fn test_day01() raises:
    test[Solution, file="tests/2024/day01.txt", part=1, expected=11]()
