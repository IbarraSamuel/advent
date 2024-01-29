const std = @import("std");

pub fn get_input(path: []const u8, comptime size: ?usize) ![]const u8 {
    var sz: usize = size orelse 1024 * 1024;
    return try std.fs.cwd().readFileAlloc(std.heap.page_allocator, path, sz);
}

pub fn read_all_file(path: []const u8, comptime size: ?usize) ![]const u8 {
    var sz: usize = size orelse 1024 * 1024;

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var raw_lines = std.ArrayList(u8).init(allocator);
    defer raw_lines.deinit();

    try reader.readAllArrayList(&raw_lines, sz);

    return raw_lines.items;
}

pub fn read_file(path: []const u8) !std.ArrayList(std.ArrayList(u8)) {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    while (reader.streamUntilDelimiter(line.writer(), '\n', null)) {
        defer line.clearRetainingCapacity();
        std.debug.print("--{s}\n", .{line.items});
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => |e| return e,
    }
}
