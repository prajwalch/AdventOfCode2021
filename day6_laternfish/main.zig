const std = @import("std");
const input = @embedFile("input.txt");

const print = std.debug.print;

pub fn main() anyerror!void {
    try partOne(80);
}

fn partOne(total_days: usize) !void {
    var fish_ages = std.ArrayList(usize).init(std.heap.page_allocator);
    defer fish_ages.deinit();

    var input_iter = std.mem.tokenize(input, ",");
    while (input_iter.next()) |raw_num| {
        var parsed_num = try std.fmt.parseInt(usize, std.mem.trimRight(u8, raw_num, "\n"), 10);
        try fish_ages.append(parsed_num);
    }

    var day: usize = 1;
    while (day <= total_days) : (day += 1) {
        //print("day {d}: ", .{day});

        for (fish_ages.items) |*age, _| {
            if (age.* == 0) {
                age.* = 6;
                try fish_ages.append(8);
            } else {
                age.* -= 1;
            }
            //print("{d},", .{age.*});
        }
        //print("\n", .{});
    }
    print("Part One: {d}\n", .{fish_ages.items.len});
}
