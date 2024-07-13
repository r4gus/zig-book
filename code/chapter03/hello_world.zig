const std = @import("std");

const Gpa = std.heap.GeneralPurposeAllocator(.{});
var gpa = Gpa{};
const allocator = gpa.allocator();

pub fn main() !void {
    const T = u8;
    const L = "Hello, World".len;

    const hello_world = allocator.alloc(T, L) catch {
        std.log.err("We ran out of memory!", .{});
        return;
    };
    defer allocator.free(hello_world);
    @memcpy(hello_world, "Hello, World");

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("{s}\n", .{hello_world});
    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
