const std = @import("std");

test "Optional" {
    const num: ?u8 = std.math.cast(u8, @as(u32, 255));

    if (num != null) {
        try std.testing.expect(num.? == 255);
    } else {
        try std.testing.expect(1 == 0); // fail
    }
}

test "Optional #2" {
    const num: ?u8 = std.math.cast(u8, @as(u32, 255));

    if (num) |n| {
        try std.testing.expect(n == 255);
    } else {
        try std.testing.expect(1 == 0); // fail
    }
}

test "Handling" {
    var num: ?u8 = std.math.cast(u8, 250);

    // Überspringe Block falls `num == null`
    if (num) |*n| {
        n.* += 1;
    }
    try std.testing.expect(num.? == 251);

    // Stelle einen Fallback-Wert bereit
    const num2: u8 = if (std.math.cast(u8, 256)) |n| n else 255;
    try std.testing.expect(num2 == 255);
}

test "while" {
    const S = struct {
        pub fn next() ?u2 {
            const T = struct {
                var v: ?u2 = 0;
            };

            defer {
                if (T.v) |*v| {
                    if (v.* == 3) T.v = null else v.* += 1;
                }
            }

            return T.v;
        }
    };

    const stdout = std.io.getStdOut();

    while (S.next()) |v| {
        try stdout.writer().print("{d}\n", .{v});
    }
}
