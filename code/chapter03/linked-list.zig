const std = @import("std");

const Elem = struct {
    prev: ?*Elem = null,
    next: ?*Elem = null,
    i: u32,

    pub fn new(i: u32, allocator: std.mem.Allocator) !*@This() {
        var self = try allocator.create(@This());
        self.i = i;
        return self;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Verkettete Liste mit drei Elementen
    var lhs = try Elem.new(1, allocator);
    defer allocator.destroy(lhs);
    var middle = try Elem.new(2, allocator);
    var rhs = try Elem.new(3, allocator);
    defer allocator.destroy(rhs);

    lhs.next = middle;
    middle.prev = lhs;

    middle.next = rhs;
    rhs.prev = middle;

    const L = lhs;
    std.log.info("Wert von lhs: {d}", .{L.i});
    std.log.info("Wert von middle: {d}", .{L.next.?.i});
    std.log.info("Wert von rhs: {d}", .{L.next.?.next.?.i});

    const x = middle;
    std.log.info("Wert von Elem referenziert von x vor deallokation: {d}", .{x.i});

    // Entfernen des mittleren Elements aus der Liste
    lhs.next = middle.next;
    rhs.prev = middle.prev;
    allocator.destroy(middle);

    std.log.info("Wert von Elem referenziert von x NACH deallokation: {d}", .{x.i});
}
