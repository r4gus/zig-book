const std = @import("std");
const print = std.debug.print;

fn myDefer() void {
    defer {
        print("Wird als zweites ausgeführt\n", .{});
    }

    defer print("Wird als erstes ausgeführt\n", .{});

    if (false) {
        defer print("Wird nie ausgeführt\n", .{});
    }
}

test "defer test #1" {
    myDefer();
}
