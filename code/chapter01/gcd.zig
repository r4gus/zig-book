const std = @import("std");

pub fn main() void {
    std.log.info("gcd of 21 and 4 is: {d}", .{gcd(21, 4)});
    std.log.info("gcd of 4 and 16 is: {d}", .{gcd(4, 16)});
}

fn gcd(n: u64, m: u64) u64 {
    return if (n == 0)
        m
    else if (m == 0)
        n
    else if (n < m)
        gcd(m, n)
    else
        gcd(m, n % m);
}

test "assert that the gcd of 21 and 4 is 1" {
    try std.testing.expectEqual(@as(u64, 1), gcd(21, 4));
}
