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

fn parse_number(comptime dir: i32, s: []const u8, pos: usize, alloc: std.mem.Allocator) struct { chr: []const u8, pos: i32 } {
    // if (dir == 0) {
    //     std.debug.print("reading line '{s}' at pos {d} with char '{c}'\n", .{ s, pos, s[pos] });
    // }
    const current_char = s[pos];
    var left: []const u8 = "";
    var lpos = pos;
    var right: []const u8 = "";
    var rpos = pos;

    if (pos > 0 and std.ascii.isDigit(s[pos - 1]) and dir <= 0) {
        const result = parse_number(-1, s, pos - 1, alloc);
        // defer alloc.free(result);
        left = result.chr;
        lpos = @intCast(result.pos);
    }
    if (pos < s.len - 1 and std.ascii.isDigit(s[pos + 1]) and dir >= 0) {
        const result = parse_number(1, s, pos + 1, alloc);
        // defer alloc.free(result);
        right = result.chr;
        rpos = @intCast(result.pos);
    }
    const current_arr: []const u8 = &[_]u8{current_char};
    const current = std.fmt.allocPrint(alloc, "{s}{s}{s}", .{ left, current_arr, right }) catch unreachable;
    alloc.free(left);
    alloc.free(right);
    const lpos_cast: i32 = @intCast(lpos);
    // const current: []const u8 = left ++ current_arr ++ right;
    return .{ .chr = current, .pos = lpos_cast };
}

fn idx(x: usize, y: usize, x_len: usize) usize {
    return x_len * y + x;
}
fn check_window(point: Point, input: []const u8, results: *hash_map.AutoHashMap(i32, void), limit: ?usize, alloc: std.mem.Allocator) !i32 {
    const x_len: i32 = @intCast(std.mem.indexOf(u8, input, "\n").? + 1);
    const y_len: i32 = @intCast(input.len);
    const min_x: usize = @intCast(@max(point.x - 1, 0));
    const max_x: usize = @intCast(@min(point.x + 1, x_len - 2));
    const min_y: usize = @intCast(@max(point.y - 1, 0));
    const max_y: usize = @intCast(@min(point.y + 1, y_len - 2));
    const x_len_: usize = @intCast(x_len);
    var values_collected: usize = 0;
    var total: i32 = 0;
    if (limit != null) {
        total = 1;
    }

    for (min_y..max_y + 1) |y| {
        for (min_x..max_x + 1) |x| {
            if (std.ascii.isDigit(input[x_len_ * y + x])) {
                const final = @min(x_len_ * (y + 1), input.len);
                const num_result = parse_number(0, input[x_len_ * y .. final], @intCast(x), alloc);
                var current_point = Point{ .x = num_result.pos, .y = @intCast(y) };
                if (!results.contains(current_point.hash())) {
                    try results.put(current_point.hash(), {});
                    const parsed_result = try std.fmt.parseUnsigned(i32, num_result.chr, 10);
                    // std.debug.print("{d}\n", .{parsed_result});
                    if (limit != null) {
                        total *= parsed_result;
                    } else {
                        total += parsed_result;
                    }
                    values_collected += 1;

                    if (values_collected > limit orelse values_collected) {
                        alloc.free(num_result.chr);
                        return 0;
                    }
                }
                alloc.free(num_result.chr);
            }
        }
    }
    if (values_collected != limit orelse values_collected) {
        return 0;
    }
    return total;
}

fn part1(lines: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();
    const x_len = std.mem.indexOf(u8, lines, "\n").? + 1;
    const y_len = lines.len / x_len;

    for (0..y_len) |y| {
        for (0..x_len - 1) |x| {
            const chr = lines[idx(x, y, x_len)];
            if (!std.ascii.isDigit(chr) and chr != '.') {
                points.append(.{ .x = @intCast(x), .y = @intCast(y) }) catch unreachable;
            }
        }
    }

    var total: i32 = 0;
    var results = hash_map.AutoHashMap(i32, void).init(allocator);
    defer results.deinit();
    for (points.items) |point| {
        total += check_window(point, lines, &results, null, allocator) catch unreachable;
    }

    return @intCast(total);
}

fn part2(lines: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();
    const x_len = std.mem.indexOf(u8, lines, "\n").? + 1;
    const y_len = lines.len / x_len;

    for (0..y_len) |y| {
        for (0..x_len - 1) |x| {
            const chr = lines[idx(x, y, x_len)];
            if (chr == '*') {
                points.append(.{ .x = @intCast(x), .y = @intCast(y) }) catch unreachable;
            }
        }
    }

    var total: i32 = 0;
    var results = hash_map.AutoHashMap(i32, void).init(allocator);
    defer results.deinit();
    for (points.items) |point| {
        total += check_window(point, lines, &results, 2, allocator) catch unreachable;
    }

    return @intCast(total);
}
