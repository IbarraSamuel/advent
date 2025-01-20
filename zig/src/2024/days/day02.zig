const std = @import("std");
pub const Solution = .{
    .part1 = part1,
    .part2 = part2,
};

fn part1(data: []u8) anyerror!i32 {
    var count: usize = 0;
    var lines_iter = std.mem.split(u8, data, "\n");
    return lines: while (lines_iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            continue;
        }
        var prev: i32 = 0;
        var orig_diff: i32 = 0;

        var num_chrs = std.mem.split(u8, line, " ");
        while (num_chrs.next()) |nms| {
            const i = try std.fmt.parseInt(i32, nms, 10);
            if (prev == 0) {
                prev = i;
                continue;
            }
            const diff: i32 = prev - i;

            var sign: i32 = 0;
            if (diff < 0) {
                sign = -1;
            } else {
                sign = 1;
            }

            if (orig_diff == 0) {
                orig_diff = sign;
                prev = i;
                continue;
            }
            if (orig_diff != sign) {
                continue :lines;
            }

            const absdiff = @abs(diff);
            if (absdiff > 3 or absdiff < 1) {
                continue :lines;
            }

            prev = i;
        }
        count += 1;
    } else @intCast(count);
}
fn part2(data: []u8) anyerror!i32 {
    _ = data;
    return 0;
}
