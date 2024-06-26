const std = @import("std");

fn DayFunction(comptime T: type) type {
    return fn ([]u8) anyerror!T;
}

pub fn AdventResult(comptime T: type) type {
    return struct {
        part_1: DayFunction(T),
        part_2: DayFunction(T),
    };
}

pub fn get_input(comptime path: []const u8, comptime size: ?usize) ![]u8 {
    const sz: usize = size orelse 1024 * 1024;
    return try std.fs.cwd().readFileAlloc(std.heap.page_allocator, path, sz);
}

pub fn run(comptime T: type, comptime AR: AdventResult(T), comptime path: []const u8) !void {
    const input = try get_input(path, null);
    const d1 = try AR.part_1(input);
    std.debug.print("day 1: {}\n", .{d1});
    const d2 = try AR.part_2(input);
    std.debug.print("day 2: {}\n", .{d2});
}
