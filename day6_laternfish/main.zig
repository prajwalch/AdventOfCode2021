const std = @import("std");
const input = @embedFile("input.txt");

const print = std.debug.print;

pub fn main() anyerror!void {
    var part_one = try simulateFishLifetime(80);
    var part_two = try simulateFishLifetime(256);

    print("Part One: {d}\n", .{part_one});
    print("Part Two: {d}\n", .{part_two});
}

fn simulateFishLifetime(total_days: usize) !u64 {
    var lifetime_table = [_]u64{0} ** 9;

    var input_iter = std.mem.tokenize(input, ",");
    while (input_iter.next()) |raw_num| {
        var fish_life = try std.fmt.parseInt(u8, std.mem.trimRight(u8, raw_num, "\n"), 10);
        lifetime_table[fish_life] += 1;
    }

    var nums_resetting_fish: u64 = 0;
    var day: usize = 1;

    while (day <= total_days) : (day += 1) {
        for (lifetime_table) |fish_num, lifetime| {
            if (lifetime == 0) {
                nums_resetting_fish = fish_num;
            } else {
                lifetime_table[lifetime - 1] = fish_num;
            }
        }
        lifetime_table[6] += nums_resetting_fish;
        lifetime_table[8] = nums_resetting_fish;
    }
    return countTotalFish(lifetime_table);
}

fn countTotalFish(lifetime_table: [9]u64) u64 {
    var count: u64 = 0;
    for (lifetime_table) |nums_fish| {
        count += nums_fish;
    }
    return count;
}
