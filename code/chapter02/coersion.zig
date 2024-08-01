const std = @import("std");

pub fn main() void {
    const a: [5]u8 = .{ 1, 2, 3, 4, 5 };

    foo(&a);
    foo(a[1..]);

    const b: [3][]const u8 = .{ "David", "Franziska", "Sarah" };

    // Zig konvertiert die Referenz automatisch zu einem Slice.
    const sb: []const []const u8 = &b;
    _ = sb;

    // `rb` ist ein Pointer zu einem Array.
    const rb: *const [3][]const u8 = &b;
    _ = rb;

    const n: usize = std.crypto.random.int(usize);
    std.log.info("{s}", .{b[0][1..n]});
}

fn foo(s: []const u8) void {
    for (s) |e| {
        std.log.info("{d}", .{e});
    }
}
