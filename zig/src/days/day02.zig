const std = @import("std");
const advent_utils = @import("../advent_utils.zig");
const AdventSolution = advent_utils.AdventSolution;
pub const Solution: AdventSolution(usize) = .{ .part1 = part1, .part2 = part2 };

// The order is: 0: red, 1: green, 2: blue
const Card = struct { usize = 0, usize = 0, usize = 0 };
const MaxCard: Card = .{ 12, 13, 14 };

fn createCard(card_str: []const u8) Card {
    var card: Card = .{};
    var colors = std.mem.splitSequence(u8, card_str, ", ");
    return while (colors.next()) |color| {
        const space_pos = std.mem.indexOf(u8, color, " ") orelse unreachable;
        const num = std.fmt.parseUnsigned(usize, color[0..space_pos], 10) catch unreachable;
        const last_char = color[color.len - 1];
        if (last_char == 'd') {
            card[0] += num;
        } else if (last_char == 'n') {
            card[1] += num;
        } else if (last_char == 'e') {
            card[2] += num;
        } else {
            unreachable;
        }
    } else card;
}

fn lessThanMax(card: Card) bool {
    return (card[0] <= MaxCard[0] and
        card[1] <= MaxCard[1] and
        card[2] <= MaxCard[2]);
}

fn calcMax(c1: Card, c2: Card) Card {
    return .{
        @max(c1[0], c2[0]),
        @max(c1[1], c2[1]),
        @max(c1[2], c2[2]),
    };
}

fn part1(input: []const u8) !usize {
    var total: usize = 0;
    var i: usize = 0;
    var lines = std.mem.splitSequence(u8, input, "\n");
    return outer: while (lines.next()) |line| {
        i += 1;
        const line_init = std.mem.indexOf(u8, line, ": ") orelse unreachable;
        var cards = std.mem.splitSequence(u8, line[line_init + 2 ..], "; ");
        while (cards.next()) |card_str| {
            const card = createCard(card_str);
            if (!lessThanMax(card)) {
                continue :outer;
            }
        }
        total += i;
    } else total;
}

fn part2(input: []const u8) !usize {
    var total: usize = 0;
    var lines = std.mem.splitSequence(u8, input, "\n");
    return while (lines.next()) |line| {
        const line_init = std.mem.indexOf(u8, line, ": ").? + 2;
        var cards = std.mem.splitSequence(u8, line[line_init..], "; ");
        var max_card: Card = .{};
        while (cards.next()) |card_str| {
            const card = createCard(card_str);
            max_card = calcMax(card, max_card);
        }
        total += (max_card[0] * max_card[1] * max_card[2]);
    } else total;
}
