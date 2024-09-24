const std = @import("std");

const MyErrors = error{
    IsNotEight,
};

fn checkNumber(n: u8) MyErrors!void {
    if (n != 8) return MyErrors.IsNotEight;
}

test "Error test #1" {
    try std.testing.expectError(MyErrors.IsNotEight, checkNumber(7));
}

// -------------------------------

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

fn coerce(err: AllocationError) FileOpenError {
    return err;
}

test "Error-Set Coercion" {
    try std.testing.expect(FileOpenError.OutOfMemory == coerce(AllocationError.OutOfMemory));
}

// -------------------------------

pub fn main() void {
    const n = 7;
    checkNumber(n) catch |e| {
        std.log.err("The number {d} is not equal 8: {any}", .{ n, e });
    };
}

// -------------------------------

test "Default-Wert" {
    const n = std.fmt.parseInt(u64, "0xdeaX", 16) catch 16;
    try std.testing.expect(n == 16);
}
