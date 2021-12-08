const std = @import("std");

pub fn main() anyerror!void {
    try partOne();
    try partTwo();
}

fn partOne() !void {
    var input = @embedFile("input.txt");
    var input_iter = std.mem.tokenize(input, "\n");

    var count: usize = 0;
    var previous_num: usize = 0;

    while (input_iter.next()) |line| {
        const current_num = try std.fmt.parseInt(usize, line, 10);
        if (previous_num > 0) {
            if (current_num > previous_num)
                count += 1;
        }
        previous_num = current_num;
    }

    std.debug.print("Part One: {d}\n", .{count});
}

fn partTwo() !void {
    var input = @embedFile("input.txt");
    var input_iter = std.mem.tokenize(input, "\n");

    var nums = std.ArrayList(usize).init(std.heap.page_allocator);
    defer nums.deinit();

    while (input_iter.next()) |line| {
        const measurement = try std.fmt.parseInt(usize, line, 10);
        try nums.append(measurement);
    }

    var count: usize = 0;
    var index: usize = 0;
    var previous_sum: usize = 0;

    while (index < nums.items.len) : (index += 1) {
        // there aren't enough measurements left to create a new three-measurement sum
        if ((index + 1) >= nums.items.len or (index + 2) >= nums.items.len)
            break;

        const current_num = nums.items[index];
        const second_num = nums.items[index + 1];
        const third_num = nums.items[index + 2];

        const current_sum = current_num + second_num + third_num;
        if (previous_sum > 0) {
            if (current_sum > previous_sum)
                count += 1;
        }
        previous_sum = current_sum;
    }

    std.debug.print("Part Two: {d}\n", .{count});
}
