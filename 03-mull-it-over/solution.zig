// Doing without regex because of Zig's current state. (。_。)
const std = @import("std");

const String = []const u8;

const INPUT_PATH: String = "input.txt";
const MAX_FILE_SIZE_B: u32 = 1024 * 1024;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    const input = read_file(allocator, INPUT_PATH) catch |err| {
        switch (err) {
            error.FileNotFound => {
                std.debug.print("Error: Could not find input file `{s}`.\n", .{INPUT_PATH});
                return err;
            },
            error.OutOfMemory => {
                std.debug.print("Error: File size exceeds the limit of `{}` bytes (`{}` MB).\n", .{ MAX_FILE_SIZE_B, MAX_FILE_SIZE_B / 1024 / 1024 });
                return err;
            },
            else => {
                std.debug.print("Error: Unexpected error while reading file: `{}`.\n", .{err});
                return err;
            },
        }
    };
    defer allocator.free(input);

    var res: usize = 0;
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        res += try match_mul_sum(line);
    }
    try stdout.print("Answer to part 1: {d}.\n", .{res});
}

fn match_mul_sum(line: String) !usize {
    var res: usize = 0;
    var i: usize = 0;
    while (i < line.len) {
        // `8` is the minimum length of a valid `mul(X,Y)` substring.
        if (i + 8 >= line.len) break;
        if (!std.mem.eql(u8, line[i .. i + 4], "mul(")) {
            i += 1;
            continue;
        }
        const x_begin: usize = i + 4;
        const x_end = match_mul_operand(line, x_begin);
        i = x_end;
        if (x_end - x_begin > 3 or line[i] != ',') continue;
        const y_begin: usize = i + 1;
        const y_end = match_mul_operand(line, y_begin);
        i = y_end;
        if (y_end - y_begin > 3 or line[i] != ')') continue;
        res += try std.fmt.parseInt(u32, line[x_begin..x_end], 10) * try std.fmt.parseInt(u32, line[y_begin..y_end], 10);
    }
    return res;
}

fn match_mul_operand(line: String, begin: usize) usize {
    var end = begin;
    while (end < line.len and std.ascii.isDigit(line[end])) : (end += 1) {}
    return end;
}

fn read_file(allocator: std.mem.Allocator, path: String) ![]u8 {
    return std.fs.cwd().readFileAlloc(allocator, path, MAX_FILE_SIZE_B);
}
