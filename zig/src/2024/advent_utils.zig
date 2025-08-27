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
        // const file = std.fs.File.stdout();
        // const writer = std.io.Writer{.vtable = };
        // const writer = std.io.getStdOut().writer();
        var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
        const gpa = gp_alloc.allocator();

        for (0..25) |i| {
            if (solver.solutions[i] == null) {
                break;
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
            std.debug.print("Day {s} =>\n", .{day});
            const res1 = try sol.part1(data);
            std.debug.print("\tPart 1: {d}\n", .{res1});
            const res2 = try sol.part2(data);
            std.debug.print("\tPart 2: {d}\n\n", .{res2});
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

pub fn run_test(comptime path: []const u8, comptime solution: Solution, comptime part: usize, comptime expected: i32) anyerror!void {
    const data = try getInput(path);
    const result: i32 = undefined;
    if (part == 1) {
        result = try solution.part1(data);
    } else if (part == 2) {
        result = try solution.part2(data);
    }

    std.debug.assert(result == expected);
}
