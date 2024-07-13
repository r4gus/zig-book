const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    // Compile error
    //var x: [10]u8 = .{0} ** 10;
    //x[10] = 1;

    var x = try allocator.alloc(u8, 10);
    x[10] = 1;
}
