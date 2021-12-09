const std = @import("std");

const GRID_SIZE: usize = 5;
const Grids = std.ArrayList([GRID_SIZE][GRID_SIZE]Cell);

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

    var grids = Grids.init(std.heap.page_allocator);
    defer grids.deinit();

    var grid_moves = input_iter.next().?;
    var grid_moves_iter = std.mem.tokenize(grid_moves, ",");

    var grids_layout = input_iter.rest();
    var grids_layout_iter = std.mem.split(grids_layout, "\n\n");

    while (grids_layout_iter.next()) |layout| {
        try parseAndMakeGrid(layout, &grids);
    }

    while (grid_moves_iter.next()) |move| {
        var move_num = try std.fmt.parseInt(isize, move, 10);
        markNum(move_num, &grids);
        //dumpGrid(&grids);
        var winner = checkWinner(&grids);
        if (winner) |sum| {
            std.debug.print("Part One: {d}*{d} = {d}\n", .{ sum, move_num, sum * move_num });
            return;
        }
    }
}

fn parseAndMakeGrid(layout: []const u8, grids: *Grids) !void {
    var grid = [_][5]Cell{
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

            outer: for (grid) |*row, i| {
                for (row) |*cell, _| {
                    if (cell.num == -1) {
                        cell.num = parsed_num;
                        break :outer;
                    }
                }
            }
        }
    }
    try grids.append(grid);
}

fn markNum(num: isize, grids: *Grids) void {
    for (grids.items) |*grid| {
        for (grid) |_, i| {
            for (grid[i]) |*cell, _| {
                if (cell.num == num and !cell.is_marked) {
                    cell.mark();
                }
            }
        }
    }
}

fn checkWinner(grids: *Grids) ?isize {
    for (grids.items) |grid| {
        var current_grid = grid;
        if (isGridWin(current_grid))
            return getSum(current_grid);
    }
    return null;
}

fn isGridWin(grid: [5][5]Cell) bool {
    var i: usize = 0;
    var j: usize = 0;

    while (i < 5) : (i += 1) {
        j = 0;
        while (j < 5) : (j += 1) {
            if (!grid[i][j].is_marked) break;
        }
        if (j >= 5) return true;

        j = 0;
        while (j < 5) : (j += 1) {
            if (!grid[j][i].is_marked) break;
        }
        if (j >= 5) return true;
    }
    return false;
}

fn dumpGrid(grids: *Grids) void {
    for (grids.items) |grid| {
        for (grid) |*row, _| {
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

fn getSum(grid: [5][5]Cell) isize {
    var sum: isize = 0;

    for (grid) |*row, _| {
        for (row) |*cell, _| {
            if (!cell.is_marked)
                sum += cell.num;
        }
    }
    return sum;
}
