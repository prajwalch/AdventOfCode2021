const std = @import("std");

const BOARD_SIZE: usize = 5;
const Boards = std.ArrayList([BOARD_SIZE][BOARD_SIZE]Cell);

const Cell = struct {
    num: isize = -1,
    is_marked: bool = false,

    const Self = @This();

    pub fn mark(self: *Self) void {
        self.is_marked = true;
    }
};

pub fn main() anyerror!void {
    try partOne();
}

fn partOne() !void {
    var input = @embedFile("input.txt");
    var input_iter = std.mem.tokenize(input, "\n ");

    var boards = Boards.init(std.heap.page_allocator);
    defer boards.deinit();

    var board_moves = input_iter.next().?;
    var board_moves_iter = std.mem.tokenize(board_moves, ",");

    var boards_layout = input_iter.rest();
    var boards_layout_iter = std.mem.split(boards_layout, "\n\n");

    while (boards_layout_iter.next()) |layout| {
        try parseAndMakeBoard(layout, &boards);
    }

    while (board_moves_iter.next()) |move| {
        var move_num = try std.fmt.parseInt(isize, move, 10);
        markNum(move_num, &boards);
        //dumpBoard(&boards);
        var winner = checkWinner(&boards);
        if (winner) |sum| {
            std.debug.print("Part One: {d}*{d} = {d}\n", .{ sum, move_num, sum * move_num });
            return;
        }
    }
}

fn parseAndMakeBoard(layout: []const u8, boards: *Boards) !void {
    var board = [_][5]Cell{
        [_]Cell{.{}} ** 5,
        [_]Cell{.{}} ** 5,
        [_]Cell{.{}} ** 5,
        [_]Cell{.{}} ** 5,
        [_]Cell{.{}} ** 5,
    };

    var layout_nums_line = std.mem.tokenize(layout, "\n");

    while (layout_nums_line.next()) |line| {
        var nums_iter = std.mem.tokenize(line, " ");

        while (nums_iter.next()) |num| {
            var parsed_num = try std.fmt.parseInt(isize, std.mem.trim(u8, num, " "), 10);

            outer: for (board) |*row, i| {
                for (row) |*cell, _| {
                    if (cell.num == -1) {
                        cell.num = parsed_num;
                        break :outer;
                    }
                }
            }
        }
    }
    try boards.append(board);
}

fn markNum(num: isize, boards: *Boards) void {
    for (boards.items) |*board| {
        for (board) |_, i| {
            for (board[i]) |*cell, _| {
                if (cell.num == num and !cell.is_marked) {
                    cell.mark();
                }
            }
        }
    }
}

fn checkWinner(boards: *Boards) ?isize {
    for (boards.items) |board| {
        var current_board = board;
        if (isBoardWin(current_board))
            return getSum(current_board);
    }
    return null;
}

fn isBoardWin(board: [5][5]Cell) bool {
    var i: usize = 0;
    var j: usize = 0;

    while (i < 5) : (i += 1) {
        j = 0;
        while (j < 5) : (j += 1) {
            if (!board[i][j].is_marked) break;
        }
        if (j >= 5) return true;

        j = 0;
        while (j < 5) : (j += 1) {
            if (!board[j][i].is_marked) break;
        }
        if (j >= 5) return true;
    }
    return false;
}

fn dumpBoard(boards: *Boards) void {
    for (boards.items) |board| {
        for (board) |*row, _| {
            for (row) |*cell, _| {
                if (cell.is_marked) {
                    std.debug.print("[{d}]  ", .{cell.num});
                } else {
                    std.debug.print("{d}  ", .{cell.num});
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("------\n", .{});
}

fn getSum(board: [5][5]Cell) isize {
    var sum: isize = 0;

    for (board) |*row, _| {
        for (row) |*cell, _| {
            if (!cell.is_marked)
                sum += cell.num;
        }
    }
    return sum;
}
