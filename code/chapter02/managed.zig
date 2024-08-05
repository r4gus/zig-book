const std = @import("std");

const String = struct {
    s: ?[]u8 = null,
    allocator: std.mem.Allocator,

    /// Erzeuge eine neue Instanz von `String` die den
    /// Speicher des Strings mit Hilfe von `allocator` verwaltet.
    pub fn init(allocator: std.mem.Allocator) @This() {
        // Wir geben an dieser stelle ein anonymes Struct-Literal zurück, dessen
        // Typ (`String`) vom Rückgabewert der Funktion abgeleitet wird.
        return .{
            // Der Standardwert für `s` ist null, daher müssen
            // wir `s` nicht explizit initialisieren.
            .allocator = allocator,
        };
    }

    /// Deinitialisiere den referenzierten String.
    pub fn deinit(self: *@This()) void {
        // Da die Freigabe von Speicher immer erfolgreich sein muss,
        // ist der Rückgabewert void, d.h. innerhalb der Funktion
        // kann kein Fehler passieren.
        if (self.s == null) return;
        // Many-Item-Pointer werden mit `free` deinitialisiert.
        self.allocator.free(self.s.?);
        // Wir weisen an dieser Stelle `s` den `null`-Wert zu um klar
        // zu machen, dass `s` kein valider Slice ist.
        self.s = null;
    }

    /// Weise dem referenzierten `String` den Wert `str` zu.
    /// Der Wert von `str` wird kopiert, d.h. der Caller behält
    /// die Ownership über `str`.
    ///
    /// Ein Aufruf dieser Funktion kann fehlschlagen, z.B. weil
    /// kein Speicher mehr zur Verfügung steht.
    pub fn set(self: *@This(), str: []const u8) !void {
        // Entweder `s` ist `null` oder es wurde bereits ein Wert gemanaged.
        if (self.s) |s| {
            // Wir reallozieren Speicher für `s`.
            const s_ = try self.allocator.realloc(s, str.len);
            @memcpy(s_, str);
            self.s = s_;
        } else {
            // Wir kopieren `str`.
            const s_ = try self.allocator.dupe(u8, str);
            self.s = s_;
        }
    }

    /// Beziehe den von `self` gemanageden String.
    pub fn get(self: *const @This()) ?[]const u8 {
        // An dieser Stelle geben wir entweder den Wert des Strings zurück oder,
        // falls dieser nicht existiert, `null`.
        return if (self.s) |s| s else null;
    }
};

test "string test" {
    const allocator = std.testing.allocator;

    var s = String.init(allocator);
    // Sie können die untere Zeile auskommentieren um zu sehen, wie
    // Sie einen Memory-Leak provozieren.
    defer s.deinit();

    try s.set("Hello, World!");
    try std.testing.expectEqualStrings("Hello, World!", s.get().?);

    try s.set("Ich liebe Kryptografie");
    try std.testing.expectEqualStrings("Ich liebe Kryptografie", s.get().?);
}
