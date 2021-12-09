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
    try partTwo();
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

fn partTwo() !void {
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

    var winners: [100]usize = undefined;
    var winners_idx: usize = 0;

    while (board_moves_iter.next()) |move| {
        var move_num = try std.fmt.parseInt(isize, move, 10);
        markNum(move_num, &boards);

        findWinnerBoard(&boards, &winners, &winners_idx);

        if (winners_idx == boards.items.len) {
            var last_winner = boards.items[winners[winners_idx - 1]];
            var sum = getSum(last_winner);
            std.debug.print("Part Two: {d}*{d} = {d}\n", .{ sum, move_num, sum * move_num });
            return;
        }
    }
}

fn parseAndMakeBoard(layout: []const u8, boards: *Boards) !void {
    var board = [_][BOARD_SIZE]Cell{
        [_]Cell{.{}} ** BOARD_SIZE,
        [_]Cell{.{}} ** BOARD_SIZE,
        [_]Cell{.{}} ** BOARD_SIZE,
        [_]Cell{.{}} ** BOARD_SIZE,
        [_]Cell{.{}} ** BOARD_SIZE,
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

fn isBoardWin(board: [BOARD_SIZE][BOARD_SIZE]Cell) bool {
    var i: usize = 0;
    var j: usize = 0;

    while (i < BOARD_SIZE) : (i += 1) {
        j = 0;
        while (j < BOARD_SIZE) : (j += 1) {
            if (!board[i][j].is_marked) break;
        }
        if (j >= BOARD_SIZE) return true;

        j = 0;
        while (j < BOARD_SIZE) : (j += 1) {
            if (!board[j][i].is_marked) break;
        }
        if (j >= BOARD_SIZE) return true;
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

fn getSum(board: [BOARD_SIZE][BOARD_SIZE]Cell) isize {
    var sum: isize = 0;

    for (board) |*row, _| {
        for (row) |*cell, _| {
            if (!cell.is_marked)
                sum += cell.num;
        }
    }
    return sum;
}

fn isAlreadyChecked(idx: usize, winners: *[100]usize) bool {
    for (winners) |winner_idx, _| {
        if (winner_idx == idx) return true;
    }
    return false;
}

fn findWinnerBoard(boards: *Boards, winners: *[100]usize, winners_idx: *usize) void {
    for (boards.items) |board, idx| {
        if (isAlreadyChecked(idx, winners))
            continue;

        if (isBoardWin(board)) {
            winners[winners_idx.*] = idx;
            winners_idx.* += 1;
        }
    }
}
