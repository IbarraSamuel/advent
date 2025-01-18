const std = @import("std");
const Runner = @import("advent_utils.zig").Runner;
const days = @import("days/index.zig");

pub fn main() !void {
    try Runner("../inputs/2024/").add(days.day01.Solution).add(days.day02.Solution).run();
}
