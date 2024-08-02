const std = @import("std");

pub fn main() void {
    var array = [_]i32{ 1, 2, 3, 4 };

    var array_ptr = array[0..].ptr;

    std.log.info("{d}", .{array_ptr[0]});
    array_ptr += 1;
    std.log.info("{d}", .{array_ptr[0]});
}
