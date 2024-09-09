const std = @import("std");

const argon2 = std.crypto.pwhash.argon2;
const XChaCha20Poly1305 = std.crypto.aead.chacha_poly.XChaCha20Poly1305;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Mode = enum {
    encrypt,
    decrypt,
};

pub fn main() !void {
    var password: ?[]const u8 = null;
    var mode: ?Mode = null;

    // Als erstes parsen wir die übergebenen Kommandozeilenargumente. Diese bestimmen
    // zum einen mit welchem Passwort die Daten verschlüsselt werden sollen und zum
    // anderen den Modus, d.h. ob ver- bzw. entschlüsselt werden soll.
    var ai = try std.process.argsWithAllocator(allocator);
    defer ai.deinit();

    while (ai.next()) |arg| {
        // `std.mem.eql` kann dazu verwendet werden zwei Strings mit einander zu vergleichen...
        if (arg.len > 11 and std.mem.eql(u8, "--password=", arg[0..11])) {
            password = arg[11..];
        } else if (arg.len >= 9 and std.mem.eql(u8, "--encrypt", arg[0..9])) {
            mode = .encrypt;
        } else if (arg.len >= 9 and std.mem.eql(u8, "--decrypt", arg[0..9])) {
            mode = .decrypt;
        }
    }

    // Sollten nicht alle benötigten Argumente übergeben worden sein, so beenden wir den Prozess.
    if (password == null or mode == null) {
        std.log.err("usage: ./encrypt --password=<password> [--encrypt|--decrypt]", .{});
        return;
    }

    // Als nächstes lesen wir die übergebenen Daten von `stdin` ein.
    const stdin = std.io.getStdIn();
    const data = try stdin.readToEndAlloc(allocator, 64_000);
    defer {
        // Wir überschreiben die Daten bevor wir den Speicher wieder freigeben.
        @memset(data, 0);
        allocator.free(data);
    }

    if (mode == .encrypt) {
        // Bei der Verschlüsselung müssen wir eine Reihe an (öffentlichen)
        // Parametern festlegen, die bei der Entschlüsselung wiederverwendet
        // werden müssen.

        // Als erstes müssen wir ein Schlüssel von unserem Passwort ableiten.
        // Hierfür verwenden wir die Argon2id Key-Derivation-Function (KDF).
        var salt: [32]u8 = undefined;
        std.crypto.random.bytes(&salt);

        var key: [XChaCha20Poly1305.key_length]u8 = undefined;
        try argon2.kdf(allocator, &key, password.?, &salt, .{
            // Die Parameter bestimmen wie aufwendig die Brechnung des Schlüssels `key` ist.
            // Damit wird verhindert, diesen durch "Brute-Forcing" brechen zu können.
            .t = 3,
            .m = 4096,
            .p = 1,
        }, .argon2id);

        // Nun können wir die Daten ver-/ bzw. entschlüsseln.

        // Der TAG wird von der encrypt() Funktion erzeugt und später von decrypt()
        // überprüft.
        var tag: [XChaCha20Poly1305.tag_length]u8 = undefined;

        // Für jede Verschlüsselung muss eine neue, einzigartige Nonce verwendet werden.
        // Da wir die eXtended Version von ChaCha20 verwenden, kann diese durch einen
        // kryptographisch sicheren Zufallszahlengenerator festgelegt werden.
        var nonce: [XChaCha20Poly1305.nonce_length]u8 = undefined;
        std.crypto.random.bytes(&nonce);

        XChaCha20Poly1305.encrypt(data, &tag, data, "", nonce, key);

        // Der Salt, Nonce und Tag müssen mit den verschlüsselten Daten serialisiert werden,
        // da wir diese später zur Entschlüsselung benötigen.
        const stdout = std.io.getStdOut();
        try std.fmt.format(stdout.writer(), "{s}:{s}:{s}:{s}", .{
            // Wir serialisieren die Binärdaten in Hexadezimal.
            std.fmt.fmtSliceHexLower(salt[0..]),
            std.fmt.fmtSliceHexLower(nonce[0..]),
            std.fmt.fmtSliceHexLower(tag[0..]),
            std.fmt.fmtSliceHexLower(data),
        });
    } else {
        // Da wir die Daten in Hexadezimal serialisiert haben, müssen wir diese
        // wieder voneinander trennen und in Binärdaten umwandeln.
        var si = std.mem.split(u8, data, ":");

        const salt = si.next();
        if (salt == null or salt.?.len != 32 * 2) {
            std.log.err("invalid data (missing salt)", .{});
            return;
        }
        var salt_: [32]u8 = undefined;
        _ = try std.fmt.hexToBytes(&salt_, salt.?);

        const nonce = si.next();
        if (nonce == null or nonce.?.len != XChaCha20Poly1305.nonce_length * 2) {
            std.log.err("invalid data (missing nonce)", .{});
            return;
        }
        var nonce_: [XChaCha20Poly1305.nonce_length]u8 = undefined;
        _ = try std.fmt.hexToBytes(&nonce_, nonce.?);

        const tag = si.next();
        if (tag == null or tag.?.len != XChaCha20Poly1305.tag_length * 2) {
            std.log.err("invalid data (missing tag)", .{});
            return;
        }
        var tag_: [XChaCha20Poly1305.tag_length]u8 = undefined;
        _ = try std.fmt.hexToBytes(&tag_, tag.?);

        const ct = si.next();
        if (ct == null) {
            std.log.err("invalid data (missing cipher text)", .{});
            return;
        }

        const pt = try allocator.alloc(u8, ct.?.len / 2);
        defer {
            @memset(pt, 0);
            allocator.free(pt);
        }

        _ = try std.fmt.hexToBytes(pt, ct.?);

        // Danach können wir die deserialisierten Daten verwenden um den Ciphertext zu entschlüsseln.
        var key: [XChaCha20Poly1305.key_length]u8 = undefined;
        try argon2.kdf(allocator, &key, password.?, &salt_, .{
            .t = 3,
            .m = 4096,
            .p = 1,
        }, .argon2id);

        try XChaCha20Poly1305.decrypt(pt, pt, tag_, "", nonce_, key);

        const stdout = std.io.getStdOut();
        try std.fmt.format(stdout.writer(), "{s}", .{pt});
    }
}
