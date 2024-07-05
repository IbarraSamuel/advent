const AdventUtils = @import("../advent_utils.zig");
const AdventSolution = AdventUtils.AdventSolution;
const get_input = AdventUtils.get_input;
const std = @import("std");
const hash_map = @import("std").hash_map;
const mapper = hash_map.StringHashMap(usize);

pub const Solution: AdventSolution(usize) = .{ .part_1 = part1, .part_2 = part2 };

fn composeNumber(input: []const u8) !usize {
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

fn calcLine(line: []const u8, map: hash_map.StringHashMap(usize)) !usize {
    var first_k: ?[]const u8 = null;
    var last_k: ?[]const u8 = null;
    var first: isize = -1;
    var last: isize = -1;

    var iter = map.keyIterator();
    while (iter.next()) |key| {
        const min_pos = std.mem.indexOf(u8, line, key.*) orelse continue;
        const max_pos = std.mem.lastIndexOf(u8, line, key.*) orelse continue;

        if (first == -1 or (min_pos != -1 and min_pos < first)) {
            first = @intCast(min_pos);
            first_k = key.*;
        }
        if (last == -1 or (max_pos != -1 and max_pos > last)) {
            last = @intCast(max_pos);
            last_k = key.*;
        }
    }

    return map.get(first_k.?).? * 10 + map.get(last_k.?).?;
}

fn part1(file_content: []u8) anyerror!usize {
    var input = std.mem.splitScalar(u8, file_content, '\n');
    var total: usize = 0;
    return while (input.next()) |line| {
        total += try composeNumber(line);
    } else total;
}

fn part2(file_content: []u8) anyerror!usize {
    var input = std.mem.splitScalar(u8, file_content, '\n');
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
    var total: usize = 0;
    return while (input.next()) |line| {
        total += try calcLine(line, map);
    } else total;
}
