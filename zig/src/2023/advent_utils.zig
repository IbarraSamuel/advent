const std = @import("std");

fn DayFunction(comptime T: type) type {
    return fn ([]u8) anyerror!T;
}

pub fn AdventSolution(comptime T: type) type {
    return struct {
        part1: DayFunction(T),
        part2: DayFunction(T),
    };
}

pub fn getInput(comptime path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gp_alloc.allocator();

    return try std.fs.cwd().readFileAlloc(gpa, path, file_size);
}

pub fn run(comptime T: type, comptime AR: AdventSolution(T), comptime path: []const u8) !void {
    const input = try getInput(path);
    const d1 = try AR.part1(input);
    std.debug.print("From {s} =>\n", .{path});
    std.debug.print("\tPart 1: {d}\n", .{d1});
    const d2 = AR.part2(input) catch {
        std.debug.print("\tPart 2: NOT IMPLEMENTED\n\n", .{});
        return;
    };
    std.debug.print("\tPart 2: {d}\n\n", .{d2});
}

pub fn testSolution(comptime T: type, comptime AR: AdventSolution(T), comptime path: []const u8, comptime expected: T, expected_2: T) !void {
    const input = try getInput(path);
    const d1 = try AR.part1(input);
    const d2 = try AR.part2(input);

    try std.testing.expectEqual(expected, d1);
    try std.testing.expectEqual(expected_2, d2);
}

pub fn testSolutions(comptime T: type, comptime AR: AdventSolution(T), comptime path: []const u8, comptime expected: T, comptime path_2: []const u8, expected_2: T) !void {
    const input = try getInput(path);
    const d1 = try AR.part1(input);
    try std.testing.expectEqual(expected, d1);

    const input_2 = try getInput(path_2);
    const d2 = try AR.part2(input_2);
    try std.testing.expectEqual(expected_2, d2);
}
