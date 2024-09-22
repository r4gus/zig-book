const std = @import("std");

fn next() i32 {
    const S = struct {
        var x: i32 = 0;
    };
    defer S.x += 1;
    return S.x;
}

test "Statische, lokale Variable" {
    try std.testing.expect(next() == 0);
    try std.testing.expect(next() == 1);
    try std.testing.expect(next() == 2);
}
