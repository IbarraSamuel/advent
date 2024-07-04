const std = @import("std");
const advent_utils = @import("../advent_utils.zig");
const AdventSolution = advent_utils.AdventSolution;
pub const Solution: AdventSolution(usize) = .{ .part_1 = part1, .part_2 = part2 };

fn part1(input: []const u8) !usize {
    var total: usize = 0;
    var lines = std.mem.splitSequence(u8, input, "\n");
    return while (lines.next()) |line| {
        total += line.len;
    } else total;
}

fn part2(input: []const u8) !usize {
    _ = input;
    return 0;
}
