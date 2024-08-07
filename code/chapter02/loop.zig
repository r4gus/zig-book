const std = @import("std");

pub fn main() void {
    const names = [_][]const u8{ "David", "Franziska", "Sarah" };

    for (names) |name| {
        std.log.info("{s}", .{name});
    }

    for (names, 0..) |name, i| {
        std.log.info("{s} ({d})", .{ name, i });
    }

    const dishes = [_][]const u8{ "Apfelstrudel", "Pasta", "Quiche" };

    for (names, dishes) |name, dish| {
        std.log.info("{s} likes {s}", .{ name, dish });
    }

    for (1..5) |i| {
        std.log.info("{d}", .{i});
        if (i == 2) break;
    }

    for (1..5) |i| {
        if (i == 2) continue;
        std.log.info("{d}", .{i});
    }

    const pname = outer: for (names) |name| {
        if (name.len > 0 and (name[0] == 'p' or name[0] == 'P'))
            break :outer name;
    } else blk: {
        break :blk "no name starts with p!";
    };
    std.log.info("found: {s}", .{pname});
}
