const std = @import("std");
const advent_utils = @import("advent_utils.zig");
const day01 = @import("days/day01.zig");
const day02 = @import("days/day02.zig");

pub fn main() !void {
    try advent_utils.run(usize, day01.Solution, "../inputs/day01.txt");
    try advent_utils.run(usize, day02.Solution, "../inputs/day02.txt");
}

test {
    try advent_utils.testSolutions(usize, day01.Solution, "../inputs/tests/day1_1.txt", 142, "../inputs/tests/day1_2.txt", 281);
    try advent_utils.testSolution(usize, day02.Solution, "../inputs/tests/day2_1.txt", 8, 2286);
}
