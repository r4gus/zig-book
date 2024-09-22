//! Ein Modul bestehend aus einem Struct `Color` und
//! einer Funktion `add(u32, u32) u32`.

const std = @import("std");

/// Eine Farbe bestehend aus Red, Green und Blue.
pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
};

/// Addition zweier Zahlen.
///
/// # Argumente
/// * `a`- Die erste Zahl
/// * `b`- Die zweite Zahl
///
/// # Rückgabewert
/// Das Resultat von `a + b`.
pub fn add(a: u32, b: u32) u32 {
    return a + b;
}

test "Main Test" {
    _ = Color;
    try std.testing.expect(add(3, 4) == 7);
}
