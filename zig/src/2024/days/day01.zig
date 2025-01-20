const std = @import("std");
pub const Solution = .{
    .part1 = part1,
    .part2 = part2,
};

fn part1(data: []u8) anyerror!i32 {
    var lines = std.mem.splitScalar(u8, data, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var l1 = std.ArrayList(usize).init(alloc);
    defer l1.deinit();
    var l2 = std.ArrayList(usize).init(alloc);
    defer l2.deinit();

    while (lines.next()) |line| {
        const sep = std.mem.indexOfScalar(u8, line, ' ') orelse continue;
        var idx: usize = 1;
        while (line[sep + idx] == ' ') {
            idx += 1;
        }
        const next = sep + idx;
        const f = try std.fmt.parseInt(usize, line[0..sep], 10);
        const l = try std.fmt.parseInt(usize, line[next..], 10);
        try l1.append(f);
        try l2.append(l);
    }

    std.mem.sort(usize, l1.items, {}, std.sort.asc(usize));
    std.mem.sort(usize, l2.items, {}, std.sort.asc(usize));

    // std.debug.print("len is {d}\n", .{l1.items.len});

    var t: u32 = 0;
    for (0..l1.items.len) |i| {
        // std.debug.print("{d} ", .{i});
        const v2: i32 = @intCast(l2.items[i]);
        const v1: i32 = @intCast(l1.items[i]);
        const r = @abs(v2 - v1);
        t += r;
    }

    return @intCast(t);
}
fn part2(data: []u8) anyerror!i32 {
    var lines = std.mem.splitScalar(u8, data, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var l1 = std.ArrayList(usize).init(alloc);
    defer l1.deinit();
    var l2 = std.ArrayList(usize).init(alloc);
    defer l2.deinit();

    while (lines.next()) |line| {
        const sep = std.mem.indexOfScalar(u8, line, ' ') orelse continue;
        var idx: usize = 1;
        while (line[sep + idx] == ' ') {
            idx += 1;
        }
        const next = sep + idx;
        const f = try std.fmt.parseInt(usize, line[0..sep], 10);
        const l = try std.fmt.parseInt(usize, line[next..], 10);
        try l1.append(f);
        try l2.append(l);
    }

    var tot: usize = 0;
    for (l1.items) |v| {
        var count: usize = 0;
        for (l2.items) |v2| {
            if (v2 == v) {
                count += 1;
            }
        }
        count *= v;
        tot += count;
    }

    return @intCast(tot);
}
