const std = @import("std");
const advent_utils = @import("../advent_utils.zig");
const AdventSolution = advent_utils.AdventSolution;

pub const Solution: AdventSolution(usize) = .{ .part_1 = part1, .part_2 = part2 };

fn part1(lines: []const u8) !usize {
    return lines.len;
}

fn part2(lines: []const u8) !usize {
    return lines.len;
}
