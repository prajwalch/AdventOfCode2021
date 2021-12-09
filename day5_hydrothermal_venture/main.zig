const std = @import("std");

const BOARD_SIZE = 991;

const Board = [BOARD_SIZE][BOARD_SIZE]usize;

pub fn main() anyerror!void {
    try partOne();
}

fn partOne() !void {
    var input = @embedFile("input.txt");
    var input_iter = std.mem.tokenize(input, "\n");

    var board = [_][BOARD_SIZE]usize{[_]usize{0} ** BOARD_SIZE} ** BOARD_SIZE;

    while (input_iter.next()) |line| {
        var line_iter = std.mem.tokenize(line, " -> ");

        var x1_y1 = std.mem.tokenize(line_iter.next().?, ",");
        var x2_y2 = std.mem.tokenize(line_iter.rest(), ",");

        var x1 = try std.fmt.parseInt(usize, x1_y1.next().?, 10);
        var y1 = try std.fmt.parseInt(usize, x1_y1.rest(), 10);
        var x2 = try std.fmt.parseInt(usize, x2_y2.next().?, 10);
        var y2 = try std.fmt.parseInt(usize, x2_y2.rest(), 10);

        if (x1 == x2) drawVerticalLine(&board, x1, y1, y2);
        if (y1 == y2) drawHorizontalLine(&board, y1, x1, x2);

        //std.debug.print("x1: {s} y1: {s}, x2: {s} y2: {s}\n", .{ x1, y1, x2, y2 });
    }
    dumpBoard(&board);
    std.debug.print("Part One: {d}\n", .{findTotalOverlapPoints(&board)});
}

fn drawVerticalLine(board: *Board, x: usize, y1: usize, y2: usize) void {
    var y1_dub = y1;
    var y2_dub = y2;
    if (y1 > y2) std.mem.swap(usize, &y1_dub, &y2_dub);

    var y = y1_dub;
    while (y <= y2_dub) : (y += 1) {
        board[y][x] += 1;
    }
}

fn drawHorizontalLine(board: *Board, y: usize, x1: usize, x2: usize) void {
    var x1_dub = x1;
    var x2_dub = x2;
    if (x1 > x2) std.mem.swap(usize, &x1_dub, &x2_dub);

    var x = x1_dub;
    while (x <= x2_dub) : (x += 1) {
        board[y][x] += 1;
    }
}

fn dumpBoard(board: *Board) void {
    for (board) |row, _| {
        for (row) |point, _| {
            if (point == 0) {
                std.debug.print(". ", .{});
            } else {
                std.debug.print("{d} ", .{point});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn findTotalOverlapPoints(board: *Board) usize {
    var count: usize = 0;

    for (board) |row, _| {
        for (row) |point, _| {
            if (point > 1)
                count += 1;
        }
    }
    return count;
}
