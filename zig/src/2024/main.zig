const std = @import("std");
const Runner = @import("advent_utils.zig").Runner;
const days = @import("days");

pub fn main() !void {
    try Runner("../inputs/2024/").add(days.day01.Solution).run();
}
