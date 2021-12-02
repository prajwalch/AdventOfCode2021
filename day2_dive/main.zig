const std = @import("std");

pub fn main() anyerror!void {
    var horizontal_pos: usize = 0;
    var depth: usize = 0;
    var aim: usize = 0;

    var file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();
    var reader = file.reader();
    var cmd_buff: [8196]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&cmd_buff, '\n')) |line| {
        var cmd_iter = std.mem.split(line, " ");
        var cmd_name = cmd_iter.next().?;
        var cmd_pos = try std.fmt.parseInt(usize, cmd_iter.rest(), 10);

        if (std.mem.eql(u8, cmd_name, "forward")) {
            horizontal_pos += cmd_pos;
            depth += aim * cmd_pos;
        } else if (std.mem.eql(u8, cmd_name, "down")) {
            aim += cmd_pos;
        } else if (std.mem.eql(u8, cmd_name, "up")) {
            aim -= cmd_pos;
        }
    }

    std.debug.print("{d}", .{horizontal_pos * depth});
}
