const AdventResult = @import("advent_utils.zig").AdventResult;
const std = @import("std");
const hash_map = @import("std").hash_map;
const mapper = hash_map.StringHashMap(usize);

pub const Result: AdventResult(usize) = .{ .part_1 = part1, .part_2 = part2 };

fn compose_number(input: []const u8) !usize {
    var first: ?usize = null;
    var second: []const u8 = undefined;

    const last = for (input) |c| {
        if (!std.ascii.isDigit(c)) {
            continue;
        }
        if (first == null) {
            first = try std.fmt.parseUnsigned(usize, &[1]u8{c}, 10);
        }
        second = &[1]u8{c};
    } else try std.fmt.parseUnsigned(usize, second, 10);

    return first.? * 10 + last;
}

fn calc_line(line: []const u8) !usize {
    var map = mapper.init(std.heap.page_allocator);
    defer map.deinit();
    try map.put("1", 1);
    try map.put("2", 2);
    try map.put("3", 3);
    try map.put("4", 4);
    try map.put("5", 5);
    try map.put("6", 6);
    try map.put("7", 7);
    try map.put("8", 8);
    try map.put("9", 9);
    try map.put("one", 1);
    try map.put("two", 2);
    try map.put("three", 3);
    try map.put("four", 4);
    try map.put("five", 5);
    try map.put("six", 6);
    try map.put("seven", 7);
    try map.put("eight", 8);
    try map.put("nine", 9);

    var min: usize = 0;
    var max = line.len;
    var min_key: []const u8 = "";
    var max_key: []const u8 = "";
    var iter = map.keyIterator();
    while (iter.next()) |key| {
        const min_pos = std.mem.indexOf(u8, line, key.*) orelse continue;
        const max_pos = std.mem.lastIndexOf(u8, line, key.*) orelse continue;
        if (min_pos <= min) {
            min = min_pos;
            min_key = key.*;
        }
        if (max <= max_pos) {
            max = max_pos;
            max_key = key.*;
        }
    }
    std.debug.print("Min value is {d} at {s} and max value is {d} at {s}\n", .{ min, min_key, max, max_key });
    return map.get(min_key).? * 10 + map.get(max_key).?;
}

fn part1(file_content: []u8) anyerror!usize {
    var input = std.mem.splitScalar(u8, file_content, '\n');
    var total: usize = 0;

    return while (input.next()) |line| {
        total += try compose_number(line);
    } else total;
}

fn part2(file_content: []u8) anyerror!usize {
    var input = std.mem.splitScalar(u8, file_content, '\n');
    var total: usize = 0;

    return while (input.next()) |line| {
        std.debug.print("{s}\n", .{line});
        total += try calc_line(line);
    } else total;
}
