const std = @import("std");

const Solution = struct {
    part1: fn ([]u8) anyerror!i32,
    part2: fn ([]u8) anyerror!i32,
};

const Solver = struct {
    path: []const u8,
    solutions: [25]Solution,

    fn add(solver: *Solver, sol: Solution) *Solver {
        const len = solver.solutions.len;
        solver.solutions[len] = sol;
        return solver;
    }

    fn run(solver: *Solver) anyerror!void {
        const writer = std.io.getStdOut().writer();
        const gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
        defer gp_alloc.deinit();
        const gpa = gp_alloc.allocator();

        for (solver.solutions, 0..) |sol, i| {
            var day = [2]u8{};
            if (i < 10) {
                day[0] = "0";
                try std.fmt.formatInt(i, i, .{}, .{}, day);
            } else {
                try std.fmt.formatInt(i, i, .{}, .{}, day);
            }

            const path = try std.fmt.allocPrint(gpa, "{s}/day{s}.txt", .{ solver.path, day });
            const data = try getInput(path);
            writer.print("Day {s} =>\n", .{day});
            const res1 = try sol.part1(data);
            writer.print("\tPart 1: {d}\n", .{res1});
            const res2 = try sol.part2(data);
            writer.print("\tPart 2: {d}\n\n", .{res2});
        }
    }
};

fn getInput(comptime path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;
    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gp_alloc.allocator();

    return try std.fs.cwd().readFileAlloc(gpa, path, file_size);
}

pub fn Runner(comptime path: []const u8) type {
    return Solver{ .path = path };
}
