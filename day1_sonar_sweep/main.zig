const std = @import("std");

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();

    var reader = file.reader();
    var buf: [2000]u8 = undefined;
    var nums = std.ArrayList(usize).init(std.heap.page_allocator);
    defer nums.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const measurement = try std.fmt.parseInt(usize, line, 10);
        try nums.append(measurement);
    }

    var count: usize = 0;
    var index: usize = 0;
    var sums = std.ArrayList(usize).init(std.heap.page_allocator);
    defer sums.deinit();

    while (index < nums.items.len) : (index += 1) {
        // there aren't enough measurements left to create a new three-measurement sum
        if ((index + 1) >= nums.items.len or (index + 2) >= nums.items.len)
            break;

        const current_num = nums.items[index];
        const second_num = nums.items[index + 1];
        const third_num = nums.items[index + 2];

        const sum_of_three = current_num + second_num + third_num;
        try sums.append(sum_of_three);
    }

    index = 1;
    while (index < sums.items.len) : (index += 1) {
        const prev_num = sums.items[index - 1];
        const current_num = sums.items[index];

        if (current_num > prev_num)
            count += 1;
    }

    std.debug.print("{d}\n", .{count});
}
