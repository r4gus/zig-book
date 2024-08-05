const std = @import("std");

const RgbColor = struct {
    // Felder mit Standardwert `0`
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,

    // Constanten für die drei Grundfarben.
    // Mit `@This()` kann auf den umschließenden Container
    // zugegriffen werden.
    const RED = @This(){ .r = 255 };
    const GREEN = @This(){ .g = 255 };
    const BLUE = @This(){ .b = 255 };

    // Eine Methode ist eine Funktion die direkt auf einem
    // Objekt aufgerufen werden kann. Ihr erster Parameter
    // ist ein Instanz oder Referenz auf eine Instanz des Typen.
    pub fn add(self: @This(), other: @This()) @This() {
        return .{
            .r = self.r +| other.r,
            .g = self.g +| other.g,
            .b = self.b +| other.b,
        };
    }
};

pub fn main() void {
    // Die Zuweisung der Felder muss nicht in der selben Reihenfolge
    // erfolgen, in der die Felder deklariert wurden.
    const red = RgbColor{ .r = 255, .b = 0, .g = 0 };
    // Angabe des Grün-Werts. Für die restlichen Felder wird der
    // Standardwert `0` übernommen.
    const green = RgbColor{ .g = 255 };
    // Zugriff auf die Konstante `BLUE` definiert in `RgbColor`
    const blue = RgbColor.BLUE;

    std.log.info("red: {any}, green: {any}, blue: {any}", .{ red, green, blue });

    // Wir addieren die Werte zweier Farben.
    const new_color = red.add(green);

    std.log.info("new_color: {any}", .{new_color});
}
