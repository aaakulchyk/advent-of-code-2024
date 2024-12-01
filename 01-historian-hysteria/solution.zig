const std = @import("std");

const NumberPair = struct {
    first: i32,
    second: i32,
};
const String = []const u8;

const COLUMNS_SEPARATOR = "   ";
const INPUT_PATH = "input.txt";
const MAX_FILE_SIZE_B = 1024 * 1024;

pub fn main() !void {
    // Get the allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = read_file(allocator, INPUT_PATH) catch |err| {
        switch (err) {
            error.FileNotFound => {
                std.debug.print(
                    "Error: Could not find input file `{s}`.\n",
                    .{INPUT_PATH}
                );
                return err;
            },
            error.OutOfMemory => {
                std.debug.print(
                    "Error: File size exceeds the limit of `{}` bytes (`{}` MB).\n",
                    .{MAX_FILE_SIZE_B, MAX_FILE_SIZE_B / 1024 / 1024}
                );
                return err;
            },
            else => {
                std.debug.print(
                    "Error: Unexpected error while reading file: `{}`.\n",
                    .{err}
                );
                return err;
            }
        }
    };
    defer allocator.free(input);

    // std.debug.print("File contents: {s}\n", .{input});

    var first_column = std.ArrayList(i32).init(allocator);
    defer first_column.deinit();
    var second_column = std.ArrayList(i32).init(allocator);
    defer second_column.deinit();
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const number_pair = parse_line(line) catch |err| {
            std.debug.print("Error parsing line: {}.\n", .{err});
            return err;
        };

        try first_column.append(number_pair.first);
        try second_column.append(number_pair.second);
    }

    std.mem.sort(i32, first_column.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, second_column.items, {}, std.sort.asc(i32));

    var distance: u64 = 0;
    for (first_column.items, second_column.items) |first, second| {
        distance += @abs(first - second);
    }

    std.debug.print("Answer to part 1: {d}.\n", .{distance});

    var value_counts = std.AutoHashMap(i32, u32).init(allocator);
    defer value_counts.deinit();

    for (first_column.items) |value| {
        try value_counts.put(value, 0);
    }
    for (second_column.items) |value| {
        if (!value_counts.contains(value)) continue;
        const count = value_counts.get(value) orelse 0;
        try value_counts.put(value, count + 1);
    }

    var weighted_distance: u64 = 0;
    var it = value_counts.iterator();
    while (it.next()) |entry| {
        const u_key: u32 = @intCast(entry.key_ptr.*);
        weighted_distance += u_key * entry.value_ptr.*;
    }

    std.debug.print("Answer to part 2: {d}.\n", .{weighted_distance});
}

fn parse_line(line: String) !NumberPair {
    var numbers = std.mem.splitSequence(u8, line, COLUMNS_SEPARATOR);
    const first_str = numbers.next() orelse return error.InvalidFormat;
    const second_str = numbers.next() orelse return error.InvalidFormat;

    const first = try std.fmt.parseInt(i32, first_str, 10);
    const second = try std.fmt.parseInt(i32, second_str, 10);
    return NumberPair { .first = first, .second = second };
}

fn read_file(allocator: std.mem.Allocator, path: String) ![]u8 {
    return std.fs.cwd().readFileAlloc(allocator, path, MAX_FILE_SIZE_B);
}
