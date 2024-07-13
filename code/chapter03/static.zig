const std = @import("std");

const hello = "Hello, World";

pub fn main() void {
    const local_context = struct {
        var x: u8 = 128;
    };

    std.log.info("{s}, {d}", .{ hello, local_context.x });
}
