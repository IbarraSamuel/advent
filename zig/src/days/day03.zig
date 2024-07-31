const std = @import("std");
const advent_utils = @import("../advent_utils.zig");
const AdventSolution = advent_utils.AdventSolution;

const hash_map = std.hash_map;

pub const Solution: AdventSolution(usize) = .{ .part1 = part1, .part2 = part2 };

const Point = struct {
    x: i32,
    y: i32,

    fn hash(self: *Point) i32 {
        return self.x * 1000000 + self.y;
    }
};

fn parse_number(comptime dir: i32, s: []const u8, pos: usize) struct { chr: []const u8, pos: i32 } {
    const current_char = s[pos];
    var left: []const u8 = "";
    var lpos = pos;
    var right: []const u8 = "";
    var rpos = pos;

    if (pos > 0 and std.ascii.isDigit(s[pos - 1]) and dir <= 0) {
        const result = parse_number(-1, s, pos - 1);
        left = result.chr;
        lpos = @intCast(result.pos);
    }
    if (pos < s.len - 1 and std.ascii.isDigit(s[pos + 1]) and dir >= 0) {
        const result = parse_number(1, s, pos + 1);
        right = result.chr;
        rpos = @intCast(result.pos);
    }
    const current_arr: []const u8 = &[_]u8{current_char};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const current = std.fmt.allocPrint(alloc, "{s}{s}{s}", .{ left, current_arr, right }) catch unreachable;
    const lpos_cast: i32 = @intCast(lpos);
    // const current: []const u8 = left ++ current_arr ++ right;
    return .{ .chr = current, .pos = lpos_cast };
}

fn check_window(point: Point, input: []const u8, results: *hash_map.AutoHashMap(i32, void)) !i32 {
    const x_len: i32 = @intCast(std.mem.indexOf(u8, input, "\n").?);
    const y_len: i32 = @intCast(input.len);
    const _x = point.x;
    const _y = point.y;
    const min_x: usize = @intCast(@max(_x - 1, 0));
    const max_x: usize = @intCast(@min(_x + 1, x_len - 1));
    const min_y: usize = @intCast(@max(_y - 1, 0));
    const max_y: usize = @intCast(@min(_y + 1, y_len - 1));
    const x_len_: usize = @intCast(x_len);
    // const y_len_: usize = @intCast(y_len);
    var total: i32 = 0;

    for (min_y..max_y + 1) |y| {
        for (min_x..max_x + 1) |x| {
            if (std.ascii.isDigit(input[x_len_ * y + x])) {
                const num_result = parse_number(0, input[x_len_ * y .. x_len_ * (y + 1)], @intCast(x));
                var current_point = Point{ .x = num_result.pos, .y = @intCast(y) };
                if (!results.contains(current_point.hash())) {
                    try results.put(current_point.hash(), {});
                    total += try std.fmt.parseUnsigned(i32, num_result.chr, 10);
                }
            }
        }
    }
    return total;
}

fn part1(lines: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();
    const x_len = std.mem.indexOf(u8, lines, "\n").?;
    const y_len = lines.len / x_len;

    for (0..y_len) |y| {
        for (0..x_len) |x| {
            if (lines[x_len * y + x] == '*') {
                points.append(.{ .x = @intCast(x), .y = @intCast(y) }) catch unreachable;
            }
        }
    }

    var total: i32 = 0;
    var results = hash_map.AutoHashMap(i32, void).init(allocator);
    defer results.deinit();
    for (points.items) |point| {
        total += check_window(point, lines, &results) catch unreachable;
    }

    return @intCast(total);
}

fn part2(lines: []const u8) !usize {
    return lines.len;
}
