const std = @import("std");
const advent_utils = @import("../advent_utils.zig");
const AdventSolution = advent_utils.AdventSolution;
pub const Solution: AdventSolution(usize) = .{ .part_1 = part1, .part_2 = part2 };

const Card = struct {
    r: usize = 0,
    g: usize = 0,
    b: usize = 0,
};
const MaxCard: Card = .{ .r = 12, .g = 13, .b = 14 };

fn createCard(card_str: []const u8) Card {
    var card: Card = .{};
    var colors = std.mem.splitSequence(u8, card_str, ", ");
    return while (colors.next()) |color| {
        const space_pos = std.mem.indexOf(u8, color, " ") orelse unreachable;
        const num = std.fmt.parseUnsigned(usize, color[0..space_pos], 10) catch unreachable;
        const last_char = color[color.len - 1];
        if (last_char == 'd') {
            card.r += num;
        } else if (last_char == 'n') {
            card.g += num;
        } else if (last_char == 'e') {
            card.b += num;
        } else {
            unreachable;
        }
    } else card;
}

fn lessThanMax(card: Card) bool {
    return (card.r <= MaxCard.r and
        card.g <= MaxCard.g and
        card.b <= MaxCard.b);
}

fn calcMax(c1: Card, c2: Card) Card {
    return .{
        .r = @max(c1.r, c2.r),
        .g = @max(c1.g, c2.g),
        .b = @max(c1.b, c2.b),
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
        total += (max_card.r * max_card.g * max_card.b);
    } else total;
}
