const std = @import("std");

pub fn main() void {
    var i: usize = 0;

    foo(&i);
}

pub fn foo(a: *u64) void {
    a.* += 1;
}
