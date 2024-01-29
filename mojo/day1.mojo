from advent_utils import read_input
from builtin.string import atol


fn calc(line: String) -> UInt32:
    let numbers = [1,2,3,4,5,6,7,8,9]

    var first = -1
    var pos = 0
    while first == -1:
        try:
            first = atol(line[pos])
        except:
            pos += 1

    var last = -1
    pos = len(line) - 1
    while last == -1:
        try:
            last = atol(line[pos])
        except:
            pos -= 1
    
    return first * 10 + last


fn part_1(values: DynamicVector[String]) -> UInt32:
    var total: UInt32 = 0
    for i in range(0, values.size):
        total += calc(values[i])

    return total


fn calc_2(line: String) -> UInt32:
    let numbers = [1,2,3,4,5,6,7,8,9]

    var first = -1
    var pos = 0
    while first == -1:
        try:
            first = atol(line[pos])
        except:
            pos += 1

    
    var last = -1
    pos = len(line) - 1
    while last == -1:
        try:
            last = atol(line[pos])
        except:
            pos -= 1
    
    return first * 10 + last


fn part_2(values: DynamicVector[String]) -> UInt32:
    var total: UInt32 = 0
    for i in range(0, values.size):
        total += calc_2(values[i])
    
    return total