const std = @import("std");

pub const Solution = struct {
    part1: *const fn ([]u8) anyerror!i32,
    part2: *const fn ([]u8) anyerror!i32,
};

const Solver = struct {
    path: []const u8,
    solutions: [25]?Solution,
    idx: usize = 0,

    pub fn add(solver: *const Solver, sol: Solution) Solver {
        var s = solver.*;
        s.solutions[solver.idx] = sol;
        s.idx += 1;
        return s;
    }

    pub fn run(solver: Solver) anyerror!void {
        const writer = std.io.getStdOut().writer();
        var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
        const gpa = gp_alloc.allocator();

        for (0..25) |i| {
            if (solver.solutions[i] == null) {
                continue;
            }
            const sol = solver.solutions[i].?;
            var buf: [2]u8 = undefined;
            var day: []u8 = undefined;

            if (i < 10) {
                day = try std.fmt.bufPrint(&buf, "0{d}", .{i + 1});
            } else {
                day = try std.fmt.bufPrint(&buf, "{d}", .{i + 1});
            }
            const path = try std.fmt.allocPrint(gpa, "{s}day{s}.txt", .{ solver.path, day });
            const data = try getInput(path);
            try writer.print("Day {s} =>\n", .{day});
            const res1 = try sol.part1(data);
            try writer.print("\tPart 1: {d}\n", .{res1});
            const res2 = try sol.part2(data);
            try writer.print("\tPart 2: {d}\n\n", .{res2});
        }
    }
};

fn getInput(path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;
    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gp_alloc.allocator();

    return try std.fs.cwd().readFileAlloc(gpa, path, file_size);
}

pub fn Runner(comptime path: []const u8) Solver {
    return Solver{ .path = path, .solutions = [_](?Solution){null} ** 25 };
}
