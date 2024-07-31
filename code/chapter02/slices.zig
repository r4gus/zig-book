const std = @import("std");

pub fn main() void {
    var a = [_]u8{ 1, 2, 3, 4 };

    std.log.info("length of a is {d}", .{a.len});

    const s = &a;

    std.log.info("length of a is still {d}", .{s.len});

    var i: usize = 0;
    while (true) : (i += 1) {
        a[i] += 1;
    }

    const x: [5]u8 = .{ 2, 3, 5, 7, 11 };
    _ = x;
    const names = [3][]const u8{ "David", "Franziska", "Sarah" };
    _ = names;
}
