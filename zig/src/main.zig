const std = @import("std");
const day1 = @import("day1.zig");

pub fn main() !void {
    const day_1_result = try day1.part1("../inputs/day1_1.txt");
    std.debug.print("Day 1 part 1: {}.\n", .{day_1_result});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
