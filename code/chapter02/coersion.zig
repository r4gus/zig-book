const std = @import("std");

pub fn main() void {
    const a: [5]u8 = .{ 1, 2, 3, 4, 5 };

    foo(&a);
    foo(a[1..]);
}

fn foo(s: []const u8) void {
    for (s) |e| {
        std.log.info("{d}", .{e});
    }
}
