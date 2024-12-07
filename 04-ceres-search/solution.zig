const std = @import("std");

const Matrix = std.ArrayList(std.ArrayList(u8));
const String = []const u8;

const INPUT_PATH: String = "input.txt";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const stdout = std.io.getStdOut().writer();

    const matrix = try read_file(allocator, INPUT_PATH);
    defer {
        for (matrix.items) |row| {
            row.deinit();
        }
        matrix.deinit();
    }
    const m = matrix.items.len;
    const n = matrix.items[0].items.len;

    var res: usize = 0;
    var i: usize = 0;
    while (i < m) : (i += 1) {
        var j: usize = 0;
        while (j < n) : (j += 1) {
            if (matrix.items[i].items[j] != 'X') continue;
            const can_up = i > 2;
            const can_right = j < n - 3;
            const can_down = i < m - 3;
            const can_left = j > 2;
            // Up
            res += @intFromBool(can_up and matrix.items[i - 1].items[j] == 'M' and matrix.items[i - 2].items[j] == 'A' and matrix.items[i - 3].items[j] == 'S');
            // Up-Right
            res += @intFromBool(can_up and can_right and matrix.items[i - 1].items[j + 1] == 'M' and matrix.items[i - 2].items[j + 2] == 'A' and matrix.items[i - 3].items[j + 3] == 'S');
            // Right
            res += @intFromBool(can_right and matrix.items[i].items[j + 1] == 'M' and matrix.items[i].items[j + 2] == 'A' and matrix.items[i].items[j + 3] == 'S');
            // Bottom-Right
            res += @intFromBool(can_down and can_right and matrix.items[i + 1].items[j + 1] == 'M' and matrix.items[i + 2].items[j + 2] == 'A' and matrix.items[i + 3].items[j + 3] == 'S');
            // Bottom
            res += @intFromBool(can_down and matrix.items[i + 1].items[j] == 'M' and matrix.items[i + 2].items[j] == 'A' and matrix.items[i + 3].items[j] == 'S');
            // Bottom-Left
            res += @intFromBool(can_down and can_left and matrix.items[i + 1].items[j - 1] == 'M' and matrix.items[i + 2].items[j - 2] == 'A' and matrix.items[i + 3].items[j - 3] == 'S');
            // Left
            res += @intFromBool(can_left and matrix.items[i].items[j - 1] == 'M' and matrix.items[i].items[j - 2] == 'A' and matrix.items[i].items[j - 3] == 'S');
            // Up-Left
            res += @intFromBool(can_up and can_left and matrix.items[i - 1].items[j - 1] == 'M' and matrix.items[i - 2].items[j - 2] == 'A' and matrix.items[i - 3].items[j - 3] == 'S');
        }
    }

    try stdout.print("Answer to part 1: {d}.\n", .{res});
}

fn read_file(allocator: std.mem.Allocator, path: String) !Matrix {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var matrix = Matrix.init(allocator);

    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();

    const reader = file.reader();
    while (true) {
        reader.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| {
            if (err == error.EndOfStream) break;
            return err;
        };
        var row = std.ArrayList(u8).init(allocator);
        try row.appendSlice(buf.items);
        try matrix.append(row);
        buf.clearRetainingCapacity();
    }

    return matrix;
}
