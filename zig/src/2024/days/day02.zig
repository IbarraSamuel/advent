const std = @import("std");
pub const Solution = .{
    .part1 = part1,
    .part2 = part2,
};

fn part1(data: []u8) anyerror!i32 {
    var count: usize = 0;
    var lines_iter = std.mem.split(u8, data, "\n");
    return while (lines_iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            continue;
        }

        var num_chrs = std.mem.split(u8, line, " ");
        var prev = try std.fmt.parseInt(i32, num_chrs.next().?, 10);

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const alloc = gpa.allocator();
        var abs = std.ArrayList(u32).init(alloc);
        var sign = std.ArrayList(i32).init(alloc);
        while (num_chrs.next()) |nms| {
            const i = try std.fmt.parseInt(i32, nms, 10);
            const f = prev - i;
            prev = i;
            try abs.append(@abs(f));
            var s: i32 = undefined;
            if (f > 0) {
                s = 1;
            } else if (f < 0) {
                s = -1;
            } else {
                s = 0;
            }
            try sign.append(s);
        }

        const min, const max = std.mem.minMax(u32, abs.items);
        if ((std.mem.allEqual(i32, sign.items, -1) or std.mem.allEqual(i32, sign.items, 1)) and (min >= 1) and (max <= 3)) {
            count += 1;
        }
    } else @intCast(count);
}
fn part2(data: []u8) anyerror!i32 {
    _ = data;
    return 0;
}
