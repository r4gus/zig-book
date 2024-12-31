const std = @import("std");
const dvui = @import("dvui");
comptime {
    std.debug.assert(dvui.backend_kind == .sdl);
}
const Backend = dvui.backend;

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

const vsync = true;
var g_backend: ?Backend = null;

const State = enum {
    start,
    num1,
    num2,
    sym2,
    num3,
    num4,
    E,
};

var display_text: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);
var state: State = .start;

pub fn main() !void {
    defer _ = gpa_instance.deinit();

    // init SDL backend (creates and owns OS window)
    var backend = try Backend.initWindow(.{
        .allocator = gpa,
        .size = .{ .w = 280.0, .h = 200.0 },
        .min_size = .{ .w = 280.0, .h = 200.0 },
        .vsync = vsync,
        .title = "Taschenrechner",
    });
    g_backend = backend;
    defer backend.deinit();

    // init dvui Window (maps onto a single OS window)
    var win = try dvui.Window.init(
        @src(),
        gpa,
        backend.backend(),
        .{},
    );
    defer win.deinit();

    main_loop: while (true) {

        // beginWait und waitTime spielen zusammen und rendern Frames
        // nur dann, wenn diese auch benötigt werden.
        const nstime = win.beginWait(backend.hasEvent());

        // Dieser Aufruf markiert den Anfang eines Frames. Nach diesem Aufruf
        // können dvui-Funktionen verwendet werden.
        try win.begin(nstime);

        // SDL hilft auch bei der Verarbeitung von Events, wie etwa
        // Tastatureingaben. Mit diesem Aufruf schicken wir alle SDL
        // Events zu dvui, zur Verarbeitung.
        const quit = try backend.addAllEvents(&win);
        if (quit) break :main_loop;

        // Mit dem folgenden Funktionsaufruf wird das Fenster zurückgesetzt.
        // Andererseits könnten Artefakte aus vorherigen Frames verbleiben,
        // die allgemein störend wirken.
        _ = Backend.c.SDL_SetRenderDrawColor(backend.renderer, 255, 255, 255, 255);
        _ = Backend.c.SDL_RenderClear(backend.renderer);

        // An dieser Stelle können wir weitere dvui-Funktionen aufrufen...
        try taschenrechner();

        // Dieser Funktionsaufruf markiert das Ende eines Frames. Es dürfen
        // keine dvui-Funktionen mehr aufgerufen werden!
        const end_micros = try win.end(.{});

        // Cursor-Management
        backend.setCursor(win.cursorRequested());
        backend.textInputRect(win.textInputRequested());

        // Render den Frame...
        backend.renderPresent();

        const wait_event_micros = win.waitTime(end_micros, null);
        backend.waitEventTimeout(wait_event_micros);
    }

    display_text.deinit();
}

pub fn taschenrechner() !void {
    var vbox = try dvui.box(@src(), .vertical, .{
        .expand = .both,
    });
    {
        // Display
        try dvui.label(
            @src(),
            "{s}",
            .{display_text.items},
            .{
                .expand = .horizontal,
                .gravity_y = 0.5,
                .gravity_x = 0.5,
            },
        );

        // Ziffernblock
        var block = try dvui.box(@src(), .vertical, .{
            .expand = .both,
            .gravity_x = 0.5,
        });
        {
            const pad: [4][4][]const u8 = .{
                .{ "7", "8", "9", "/" },
                .{ "4", "5", "6", "*" },
                .{ "1", "2", "3", "-" },
                .{ "0", ",", "=", "+" },
            };

            for (pad, 0..) |row, id1| {
                var row_box = try dvui.box(@src(), .horizontal, .{
                    .gravity_x = 0.5,
                    .id_extra = id1,
                });

                for (row, 0..) |elem, id2| {
                    if (try dvui.button(@src(), elem, .{}, .{
                        .gravity_y = 0.5,
                        .corner_radius = dvui.Rect.all(0.0),
                        .min_size_content = dvui.Size.all(16.0),
                        .id_extra = id2,
                    })) {
                        try addValue(elem[0]);
                    }
                }

                row_box.deinit();
            }
        }
        block.deinit();
    }
    vbox.deinit();

    try eval();
}

fn addValue(v: u8) !void {
    switch (state) {
        .start => {
            if (isDigit(v)) {
                try display_text.append(v);
                state = .num1;
            }
        },
        .num1 => {
            if (isDigit(v)) {
                try display_text.append(v);
            } else if (isSym(v)) {
                // Wir nutzen ein Leerzeichen um Zahlen von +, -, * oder /
                // zu trennen. Das erleichtert uns später das Parsen.
                try display_text.append(' ');
                try display_text.append(v);
                state = .sym2;
            } else if (v == ',') {
                try display_text.append(v);
                state = .num2;
            }
        },
        .num2 => {
            if (isDigit(v)) {
                try display_text.append(v);
            } else if (isSym(v)) {
                try display_text.append(' ');
                try display_text.append(v);
                state = .sym2;
            }
        },
        .sym2 => {
            if (isDigit(v)) {
                try display_text.append(' ');
                try display_text.append(v);
                state = .num3;
            }
        },
        .num3 => {
            if (isDigit(v)) {
                try display_text.append(v);
            } else if (v == '=') {
                state = .E;
            } else if (v == ',') {
                try display_text.append(v);
                state = .num4;
            }
        },
        .num4 => {
            if (isDigit(v)) {
                try display_text.append(v);
            } else if (v == '=') {
                state = .E;
            }
        },
        .E => {}, // Nichts zu tun...
    }
}

fn isDigit(v: u8) bool {
    return v >= 0x30 and v <= 0x39;
}

fn isSym(v: u8) bool {
    return v == '+' or v == '-' or v == '*' or v == '/';
}

fn eval() !void {
    // Die Auswertung findet nur statt, sollten wir im
    // Endzustand sein.
    switch (state) {
        .E => {
            // Wir müssen das Komma durch einen Punkt ersetzen,
            // da ansonsten der Parser einen Fehler wirft.
            for (display_text.items) |*item| {
                if (item.* == ',') item.* = '.';
            }

            // Als nächstes teilen wir den String an den Leerzeichen.
            var iter = std.mem.splitSequence(u8, display_text.items, " ");

            // Erste Zahl
            const n1_ = iter.next().?;
            const n1 = if (n1_[n1_.len - 1] == '.') n1_[0 .. n1_.len - 1] else n1_;
            // Symbol
            const sym = iter.next().?;
            // Zweite Zahl
            const n2_ = iter.next().?;
            const n2 = if (n2_[n2_.len - 1] == '.') n2_[0 .. n2_.len - 1] else n2_;

            // Nun müssen wir die Zahlenstrings in eine Fließkommazahl
            // umwandeln. Hierzu haben wir im Vornhinein die Kommas
            // durch Punkte ersetzt.
            const num1 = try std.fmt.parseFloat(f128, n1);
            const num2 = try std.fmt.parseFloat(f128, n2);

            // Je nach Symbol führen wir eine andere mathematische
            // Operation aus.
            const res = switch (sym[0]) {
                '+' => num1 + num2,
                '-' => num1 - num2,
                '*' => num1 * num2,
                '/' => num1 / num2,
                else => unreachable,
            };

            // Jetzt schreiben wir das Ergebnis zurück in den `display_text`.
            display_text.clearAndFree();
            try display_text.writer().print("{d}", .{res});

            // Sollte das Ergebnis kein Komma enthalten, sind wir wieder
            // in Zustand num1...
            state = .num1;
            for (display_text.items) |*item| {
                if (item.* == '.') {
                    item.* = ',';
                    // ...ansonsten sind wir in Zustand num2.
                    state = .num2;
                }
            }
        },
        else => {},
    }
}
