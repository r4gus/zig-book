test "Konvertierungs-Test: pass" {
    var a: u16 = 0x00ff; // runtime-known
    _ = &a;
    const b: u8 = @intCast(a);
    _ = b;
    const c = @as(u8, @intCast(a));
    _ = c;
}

test "Konvertierungs-Test: fail" {
    var a: u16 = 0x00ff; // runtime-known
    _ = &a;
    //const b: u7 = @intCast(a);
    //_ = b;
}

test "Float Konvertierung" {
    var a: f32 = 1234567.0; // runtime-known
    _ = &a;
    const b: f16 = @floatCast(a);
    _ = b;
}
