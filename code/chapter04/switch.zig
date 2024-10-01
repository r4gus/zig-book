const std = @import("std");

test "basic switch statement" {
    const a: u64 = 7;
    var b: u64 = 5;

    switch (b) {
        // Jeder Zweig kann aus einem einzigen Wert bestehen.
        1 => b += a,
        // Mehrere Wert können mit `,` verknüpft werden.
        2, 3, 4, 5, 6 => b *= a,
        // Auf der Rechten Seite des `=>` kann neben einem
        // Ausdruck auch ein Block stehen.
        7 => {
            b -= a;
        },
        // Als Muster für einen Zweig können beliebige Ausdrücke
        // verwendet werden, solange diese zur Kompilierzeit
        // bekannt sind!
        blk: {
            const x = 5;
            const y = 3;
            break :blk x + y;
        } => b /= a,
        // Der `else`-Zweig deckt alles bisher nicht abgedeckte ab.
        else => b = a,
    }

    try std.testing.expectEqual(@as(u64, 35), b);
}

test "basic switch expression" {
    const a: u64 = 7;
    var b: u64 = 5;

    b = switch (b) {
        // `b + a` ist ein Ausdruck, dessen Resultat, falls der Zweig
        // ausgewählt wird, als Resultat des `switch`-Ausdrucks verwendet
        // wird.
        1 => b + a,
        2, 3, 4, 5, 6 => b * a,
        // Durch die Verwendung eines Labels (in diesem Fall `blk`). kann
        // das Ergebnis von `b - a` aus dem Block herausgereicht werden.
        7 => blk: {
            break :blk b - a;
        },
        blk: {
            const x = 5;
            const y = 3;
            break :blk x + y;
        } => b / a,
        else => a,
    };

    try std.testing.expectEqual(@as(u64, 35), b);
}
