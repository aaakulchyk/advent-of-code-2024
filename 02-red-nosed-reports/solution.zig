const std = @import("std");

const String = []const u8;

const Report = struct {
    levels: std.ArrayList(i32),

    fn deinit(self: *const Report) void {
        self.levels.deinit();
    }

    fn is_safe(self: *const Report) bool {
        if (self.levels.items.len < 2) return true;
        const report_is_asc = self.levels.items[0] < self.levels.items[1];
        for (self.levels.items[0 .. self.levels.items.len - 1], self.levels.items[1..]) |current, next| {
            const is_asc = current < next;
            const diff = @abs(current - next);
            if (is_asc != report_is_asc or diff == 0 or diff > 3) return false;
        }
        return true;
    }
};

const INPUT_PATH: String = "input.txt";
const MAX_FILE_SIZE_B: u32 = 1024 * 1024;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

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

    var n_safe: u32 = 0;
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const report = try parse_report(allocator, line);
        defer report.deinit();
        n_safe += @intFromBool(report.is_safe());
    }

    std.debug.print("Answer to part 1: {d}.\n", .{n_safe});
}

fn parse_report(allocator: std.mem.Allocator, line: String) !Report {
    var string_levels = std.mem.splitScalar(u8, line, ' ');
    var levels = std.ArrayList(i32).init(allocator);
    while (string_levels.next()) |string_level| {
        const level = std.fmt.parseInt(i32, string_level, 10) catch |err| {
            std.debug.print("Failed to parse string `{s}`.\n", .{string_level});
            return err;
        };
        try levels.append(level);
    }
    return .{ .levels = levels };
}

fn read_file(allocator: std.mem.Allocator, path: String) ![]u8 {
    return std.fs.cwd().readFileAlloc(allocator, path, MAX_FILE_SIZE_B);
}
