const print = @import("std").debug.print;
const utils = @import("advent_utils.zig");
const std = @import("std");

pub fn compose_number(input: []const u8) !usize {
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

pub fn part1(path: []const u8) !usize {
    var file_content = try utils.get_input(path, null);
    var input = std.mem.splitScalar(u8, file_content, '\n');
    var total: usize = 0;

    return while (input.next()) |line| {
        total += try compose_number(line);
    } else total;
}
