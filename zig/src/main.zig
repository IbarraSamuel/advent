const std = @import("std");
const run = @import("advent_utils.zig").run;
const day01 = @import("day01.zig");

pub fn main() !void {
    try run(usize, day01.Result, "../inputs/day01.txt");
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
