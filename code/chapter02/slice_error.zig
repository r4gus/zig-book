const std = @import("std");

pub fn main() void {
    const a = "this won't work";

    //const n: usize = std.crypto.random.int(usize);
    const n: usize = 20;
    std.log.info("{s}", .{a[1..n]});
}
