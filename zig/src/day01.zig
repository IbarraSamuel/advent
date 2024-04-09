const AdventResult = @import("advent_utils.zig").AdventResult;
const std = @import("std");
const hash_map = @import("std").hash_map;
const mapper = hash_map.AutoHashMap([]const u8, usize);

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

fn calc_line(input: []const u8) usize {
    var map = mapper.init(std.heap.PageAllocator);
    defer map.deinit();
    map.put("1", 1);
    map.put("2", 2);
    map.put("3", 3);
    map.put("4", 4);
    map.put("5", 5);
    map.put("6", 6);
    map.put("7", 7);
    map.put("8", 8);
    map.put("9", 9);
    map.put("one", 1);
    map.put("two", 2);
    map.put("three", 3);
    map.put("four", 4);
    map.put("five", 5);
    map.put("six", 6);
    map.put("seven", 7);
    map.put("eight", 8);
    map.put("nine", 9);

    var total = 0;
    while map.keyIterator()
    return total;
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
        total += try compose_number(line);
    } else total;
}
