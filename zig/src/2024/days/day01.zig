const std = @import("std");
pub const Solution = .{
    .part1 = part1,
    .part2 = part2,
};

fn part1(data: []u8) anyerror!i32 {
    const lines = std.mem.splitScalar(u8, data, '\n');
    var l1 = std.ArrayList(usize){};
    var l2 = std.ArrayList(usize){};

    while (lines.next()) |line| {
        const sep = std.mem.indexOf(u8, line, ' ').?;
        var idx: usize = 1;
        while (line[sep + 1] == ' ') {
            idx += 1;
        }
        const next = idx;
        const f = try std.fmt.parseInt(usize, line[0..sep], 10);
        const l = try std.fmt.parseInt(usize, line[next..], 10);
        l1.append(f);
        l2.append(l);
    }

    std.mem.sort(l1, {}, std.sort.asc(u8));
    std.mem.sort(l2, {}, std.sort.asc(u8));

    var t: i32 = 0;
    for (0..l1.size()) |i| {
        const v2: i32 = @intCast(l2[i]);
        const v1: i32 = @intCast(l1[i]);
        const r = @abs(v2 - v1);
        t += r;
    }

    return t;
}
fn part2(data: []u8) anyerror!i32 {
    _ = data;
    return 0;
}
