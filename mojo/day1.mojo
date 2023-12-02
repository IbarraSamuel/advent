fn main() raises -> None:
    var value: String = ""
    var pos = 0
    var accum = 0
    with open("../inputs/day1_1.txt", "r") as f:
        value = f.read()

    var only_numbers: String = ""
    for loc in range(0, len(value)):
        if value[loc] == "\n" or value[loc] == "1" or value[loc] == "2" or value[loc] == "3" or value[loc] == "4" or value[loc] == "5" or value[loc] == "6" or value[loc] == "7" or value[loc] == "8" or value[loc] == "9":
            only_numbers += value[loc]
    
    for loc in range(0, len(only_numbers)):
        if only_numbers[loc] == "\n":
            accum += atol(only_numbers[pos] + only_numbers[loc - 1])
            pos = loc + 1
            
    print(accum)
