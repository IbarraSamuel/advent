const std = @import("std");

fn DayFunction(comptime T: type) type {
    return fn ([]u8) anyerror!T;
}

pub fn AdventSolution(comptime T: type) type {
    return struct {
        part_1: DayFunction(T),
        part_2: DayFunction(T),
    };
}

pub fn get_input(comptime path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gp_alloc.allocator();

    return try std.fs.cwd().readFileAlloc(gpa, path, file_size);
}

pub fn run(comptime T: type, comptime AR: AdventSolution(T), comptime path: []const u8) !void {
    const input = try get_input(path);
    const d1 = try AR.part_1(input);
    std.debug.print("day 1: {}\n", .{d1});
    const d2 = try AR.part_2(input);
    std.debug.print("day 2: {}\n", .{d2});
}

pub fn test_solution(comptime T: type, comptime AR: AdventSolution(T), comptime path: []const u8, comptime expected: T, expected_2: T) !void {
    const input = try get_input(path);
    const d1 = try AR.part_1(input);
    const d2 = try AR.part_2(input);

    try std.testing.expectEqual(d1, expected);
    try std.testing.expectEqual(d2, expected_2);
}

pub fn test_solutions(comptime T: type, comptime AR: AdventSolution(T), comptime path: []const u8, comptime expected: T, comptime path_2: []const u8, expected_2: T) !void {
    const input = try get_input(path);
    const d1 = try AR.part_1(input);
    try std.testing.expectEqual(d1, expected);

    const input_2 = try get_input(path_2);
    const d2 = try AR.part_2(input_2);
    try std.testing.expectEqual(d2, expected_2);
}
