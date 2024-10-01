const std = @import("std");

pub fn main() !void {
    const temp = 31;
    if (temp < 20) {
        std.debug.print("Es hat {d} Grad! Pack ne Jacke ein!", .{temp});
    } else if (temp > 30) {
        std.debug.print("Wow {d} Grad! Pack die Badehose ein!", .{temp});
    } else {
        std.debug.print("Eigentlich ganz schön heute!", .{});
    }

    // oder...

    const nachricht =
        if (temp < 20)
        "Pack ne Jacke ein!"
    else if (temp > 30)
        "Pack die Badehose ein!"
    else
        "Eigentlich ganz schön heute!";
    std.debug.print(nachricht, .{});
}

test "error capture #1" {
    const a: anyerror!u32 = 7;
    if (a) |value| {
        try std.testing.expect(value == 7);
    } else |err| {
        _ = err;
        unreachable;
    }
}

test "error capture #2" {
    const a: anyerror!u32 = 7;
    const value = if (a) |value| value else |_| {
        unreachable;
    };
    try std.testing.expect(value == 7);
}

test "optionals capture #1" {
    const a: ?u32 = 7;
    if (a) |value| {
        try std.testing.expect(value == 7);
    } else {
        // Mach etwas falls `a == null`
    }
}

test "optionals with pointer-capture #1" {
    var a: ?u32 = 7;
    if (a) |*value| {
        try std.testing.expect(value.* == 7);
        value.* += 1;
    }
    try std.testing.expect(a == 8);
}
