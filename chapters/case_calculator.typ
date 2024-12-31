#import "../tip-box.typ": tip-box, code

= Hands-On: Taschenrechner

Jetzt wird es Zeit, dass wir die ganze Theorie einmal in die Praxis umsetzen. Das Ziel: einen Taschenrechner programmieren. Am Ende dieses Kapitels werden Sie einen Taschenrechner in den Händen halten, der die grundlegenden Rechenoperationen Plus, Minus, Mal und Geteilt unterstützt.

#figure(
  image("../images/calculator/calculator_skizze.png", width: 40%),
  caption: [
    Skizze des zu programmierenden Taschenrechners
  ],
)

Für die graphische Benuteroberfläche (GUI) unseres Taschenrechners verwenden wir dvui #footnote[https://github.com/david-vanderson/dvui], eine Immediate-Mode-GUI-Library. Vereinfacht ausgedrückt bedeutet Immediate-Mode #footnote[https://de.wikipedia.org/wiki/Immediate_Mode_(Computergrafik)], dass dvui keine Widgets zwischen den Frames speichert. Das heißt graphische Elemente sind nur dann sichtbar, wenn ein entsprechendes Kommando zum Zeichnen des Elements auch tatsächlich innerhalb des Frames ausgeführt wurde. 

Dvui unterstützt verschiedene Backends, auf denen dvui aufbauen kann. Backends sind Low-Level-Bibliotheken die Zugriff zu Audio, Tastatur, Maus und Graphikhardware (etwa OpenGL) bieten. Das Backend, welches wir für dvui verwenden werden werden, heißt SDL #footnote[https://www.libsdl.org/]. SDL steht für die meisten gängigen Betriebssysteme zur Verfügung, darunter Windos, Linux, macOS, iOS und Android. Wir müssen uns jedoch nicht direkt mit SDL herumschlagen. Dvui bietet eine intuitive API durch die sich GUIs beschreiben lassen ohne sich Gedanken um Low-Level-Konzepte machen zu müssen. 

Dvui befindet sich, genau wie Zig selbst, noch in Entwicklung, weshalb wir für unsren Taschenrechner einen spezifischen Git-Commit verwenden, der in diesem Buch verwendeten Zig-Version kompatibel ist.

== Projekt anlegen

Erzeugen Sie einen neuen Projektordner mit dem Namen _taschenrechner_ und initialisieren Sie diesen.

```bash
$ cd taschenrechner/
$ zig init
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
info: see `zig build --help` for a menu of options
```

Fügen Sie danach dvui als Dependency zu _build.zig.zon_ hinzu.

#code(
```zig
.dependencies = .{
    .dvui = .{
        .url = "https://github.com/david-vanderson/dvui/archive/316de718eef5166cbdf9125656b35abaeb621445.tar.gz",
        .hash = "12202bc99ddacde83c39ae59dc29b31b192ea20c9c67f62a4cffb19b2d2a31f0bccb",
    },
},
```,
caption: [taschenrechner/build.zig.zon])

Innerhalb von _build.zig_ können Sie im Anschluss auf die dvui Dependency zugreifen und das darin enthaltene Modul `dvui_sdl` importieren. Grundsätzlich kann eine Dependency mehrere Module und andere Ressourcen exportieren. Wie genau diese zu verwenden sind wird im besten Fall durch die jeweilige Dokumentation deutlich. Im Fall von dvui gibt es ein eigenständiges Demoprojekt #footnote[https://github.com/david-vanderson/dvui-demo], das als Vorlage dient.

#code(
```zig
pub fn build(b: *std.Build) void {
    // ...

    const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize });
    
    // ...

    exe.root_module.addImport("dvui", dvui_dep.module("dvui_sdl"));

    // ...
}
```,
caption: [taschenrechner/build.zig])

Durch `addImport` importieren wir `dvui_sdl` unter dem Namen `dvui`, das heißt wir können im Anschluss mit `@import("dvui")` auf das Modul zugreifen.

== Hello dvui

Als nächstes brauchen wir ein Fenster, in dem unser Taschenrechner angezeigt werden soll. Kopieren sie hierfür den folgenden Code in _main.zig_.

#code(
```zig
const std = @import("std");
const dvui = @import("dvui");
comptime {
    std.debug.assert(dvui.backend_kind == .sdl);
}
const Backend = dvui.backend;

// Definiere einen Allokator für die Speicherallokation.
var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

const vsync = true;
var g_backend: ?Backend = null;

pub fn main() !void {
    defer _ = gpa_instance.deinit();

    // SDL-Backend initialisieren (erzeugt ein eigens Fenster)
    var backend = try Backend.initWindow(.{
        .allocator = gpa,
        .size = .{ .w = 400.0, .h = 600.0 },
        .min_size = .{ .w = 400.0, .h = 600.0 },
        .vsync = vsync,
        .title = "Taschenrechner",
    });
    g_backend = backend;
    defer backend.deinit();

    // Fenster wird initialisiert
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
}
```,
caption: [taschenrechner/src/main.zig])

Der obige Code besteht aus zwei Hauptteilen: dem Erzeugen eines neuen Fensters und der Hauptschleife `main_loop`. Die Funktion `initWindow` erwartet verschiedene Optionen, wobei für die meisten Standardwerte definiert sind, die automatisch übernommen werden. Für die Allokation von dynamischem Speicher verwenden wir einen `GeneralPurposeAllocator`, als initiale Fenstergröße geben wir 400 mal 600 Pixel an und der Titel unserer Applikation ist _Taschenrechner_.

Innerhalb von `main_loop` implementieren wir den Hauptteil der Anwendung. Die zu sehenden Funktionsaufrufe sind dabei Boiler-Plate-Code und bei allen dvui-Anwendungen mehr oder weniger gleich.

Wenn Sie nun *`zig build run`* ausführen, sollten Sie ein leeres Fenster mit dem Titel _Taschenrechner_ sehen.

#figure(
  image("../images/calculator/trechner_empty.png", width: 40%),
  caption: [
    Fenster des Taschenrechners ohne weitere Widgets
  ],
)

== User Interface

Unser Taschenrechner besteht rein konzeptionell aus zwei Teilen: einer Anzeige und einem Nummernblock, wobei der Block wiederum in einzelne Tasten unterteilt werden kann. Durch drücken dieser Tasten lässt sich der Zustand des Taschenrechners verändern, welcher über die Anzeige zurück an den Nutzer gespiegelt wird. Der interne Zustand kann dabei als Zustandsautomat betrachtet werden. Bevor wir uns jedoch um die Logik des Taschenrechners kümmern, wenden wir uns der Nutzeroberfläche zu.

Als erstes fügen wir einen Puffer für die Nutzereingaben hinzu. Hierfür bietet sich eine `ArrayList(u8)` an, welche eine lineare Sequenz an Bytes darstellt. Der Vorteil von `ArrayList` gegenüber einem Array ist, dass sich `ArrayList`s mühelos erweitern lassen, ohne das wir uns Gedanken über den zu allozierenden Speicher machen müssen.

#code(
```zig
// ...

var display_text: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);

// ...

pub fn main() !void {
    // ...

    display_text.deinit(); 
}
```,
caption: [taschenrechner/src/main.zig])

Die Variable `display_text`, an die unsere `ArrayList(u8)` gebunden wird, definieren wir im umschließenden Kontainer der Main-Funktion. Der Grund hierfür ist lediglich, dass wir damit auch von anderen Funktionen, innerhalb von _main.zig_, auf die Variable zugreifen können. Da unsere Anwendung mit nur einem Thread auskommt, ist das auch in Ordnung und wir müssen uns keine Gedanken um etwaige Wettlaufsituationen (Race-Condition/ -Hazard) #footnote[https://de.wikipedia.org/wiki/Wettlaufsituation] machen. Außerhalb von Funktionen können wir außerdem kein `defer` verwenden, weshalb wir `display_text` am Ende der Main-Funktion deinitialisieren, das heißt den allozierten Speicher wieder freigeben.

Für das Layout des Taschenrechners definieren wir eine Funktion mit dem Namen `taschenrechner` (ja ich weiß... sehr originär), die innerhalb der Hauptschleife aufgerufen wird.

#code(
```zig

pub fn main() !void {
    
    // ...

    main_loop: while (true) {
        
        // ...

        // An dieser Stelle können wir weitere dvui-Funktionen aufrufen...
        try taschenrechner();
        
        // ...

    }

    // ...

}

pub fn taschenrechner() !void {
    var vbox = try dvui.box(@src(), .vertical, .{});
    {
        // Display
        try dvui.label(
            @src(),
            "{s}",
            .{display_text.items},
            .{ .gravity_y = 0.5 },
        );

        // Ziffernblock
        var block = try dvui.box(@src(), .vertical, .{});
        {
            var row1 = try dvui.box(@src(), .horizontal, .{});
            {
                if (try dvui.button(@src(), "7", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('7');
                }
                if (try dvui.button(@src(), "8", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('8');
                }
                if (try dvui.button(@src(), "9", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('9');
                }
                if (try dvui.button(@src(), "/", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('/');
                }
            }
            row1.deinit();

            var row2 = try dvui.box(@src(), .horizontal, .{});
            {
                if (try dvui.button(@src(), "4", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('4');
                }
                if (try dvui.button(@src(), "5", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('5');
                }
                if (try dvui.button(@src(), "6", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('6');
                }
                if (try dvui.button(@src(), "*", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('*');
                }
            }
            row2.deinit();

            var row3 = try dvui.box(@src(), .horizontal, .{});
            {
                if (try dvui.button(@src(), "1", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('1');
                }
                if (try dvui.button(@src(), "2", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('2');
                }
                if (try dvui.button(@src(), "3", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('3');
                }
                if (try dvui.button(@src(), "-", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('-');
                }
            }
            row3.deinit();

            var row4 = try dvui.box(@src(), .horizontal, .{});
            {
                if (try dvui.button(@src(), "0", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('0');
                }
                if (try dvui.button(@src(), ",", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append(',');
                }
                if (try dvui.button(@src(), "=", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('=');
                }
                if (try dvui.button(@src(), "+", .{}, .{ .gravity_y = 0.5 })) {
                    try display_text.append('+');
                }
            }
            row4.deinit();
        }
        block.deinit();
    }
    vbox.deinit();
}
```,
caption: [taschenrechner/src/main.zig])

Dvui erlaubt es mit einer Box mehrere graphische Elemente entweder horizontal (`.horizontal`) oder vertikal (`.vertical`) anzuordnen. Mit einem Aufruf der Funktion `box()` wird eine Container vom Typ Box geöffnet. Wird die `deinit()` Methode auf einer Box-Variable aufgerufen, so ist dies mit dem Schließen des Containers gleichzusetzen. Damit sind alle graphischen Element, zum Beispiel ein Button der mit der `button()` Funktion erzeugt wird, die zwischen der Definition einer Containervariable und dem Aufruf von `deinit()` erzeugt werden automatisch Teil des Containers.

Die GUI unseres Taschenrechners besteht aus einer vertikalen Box `vbox` die zwei Elemente enthält: das Display, welches die Eingabe anzeigt, und dem Ziffernblock.

Für das Display verwenden wir die Funktion `label()` mit der Text dargestellt wird. Die Funktion erwartet unter anderem einen Format-String, sowie eine beliebige Anzahl an Ausdrücken, deren Werte in den Format-String übernommen werden sollen. In unserem Fall soll nur der Inhalt von `display_text` angezeigt werden. Aus diesem Grund verwenden wir den Format-String `"{s}"` (`{s}` steht für ersetze durch String) und übergeben als zugehörigen Ausdruck den in der `ArrayList` gespeicherten String.

Der Ziffernblock besteht aus einer vertikalen Box, die insgesamt vier horizontale Boxen umschließt. Jeder der horizontalen Boxen enthält vier Buttons, die jeweils eine Taste unseres Taschenrechners darstellen. Der Vorteil von dvui ist, dass wir für Buttons nicht umständlich Callbacks registrieren müssen (vielleicht erinnern Sie sich noch an das GTK-Beispiel aus Kapitel 1), stattdessen gibt jeder Button direkt `true` zurück, sollte er gedrückt worden sein. Das heißt wir können einfach mit `if` überprüfen ob der jeweilige Button gedrückt wurde und eine gewünschte Aktion ausführen. Fürs Erste begnügen wir uns damit, das Symbol der jeweiligen gedrückten Taste an `display_text` anzufügen.

Nach erneutem kompilieren und starten der Anwendung sollten Sie das folgende sehen.

#figure(
  image("../images/calculator/trechner_basic.png", width: 40%),
  caption: [
    Taschenrechner mit grundlegendem Layout aber ohne Logik
  ],
)

== Zustände Bitte

Um die Logik des Taschenrechners zu implementieren gibt es verschiedene Ansätze. Manche Mathematikbibliotheken besitzen zum Beispiel eine `eval()` Funktion, mit der sich beliebige mathematische Ausdrücke evaluieren lassen. Die Logik unseres Taschenrechners implementieren wir jedoch selber. Damit dies nicht komplett ausartet, reduzieren wir die Möglichkeiten des Taschenrechners auf ein Minimum.

Der in @fsm abgebildete Taschenrechner akzeptiert Ausdrücke bestehend aus genau zwei (Fließkomma-)Zahlen, getrennt durch ein mathematisches Symbol `sym` (Plus `+`, Minus `-`, Mal `*` oder Geteilt `/`) #footnote[Die theoretischen Informatiker mögen mir den verunstalteten Automaten verzeihen.].

Ausgehen vom initialen Zustand `start` können wir eine beliebige Folge an Ziffern (Null bis Neun) eingeben. Danach folgt entweder ein Komma oder eines der erlaubten, mathematischen Symbole. Nach dem Symbol folgt wieder eine (Fließkomma-)Zahl. Durch Eingabe des Gleichheitszeichens `=` erreichen wir den Endzustand, das heißt der Ausdruck wird ausgewertet und auf dem Display des Taschenrechners angezeigt. Folgt keine Ziffer hinter einem Komma, so wird dieses bei der Auswertung ignoriert.

Eingaben für die keine Kante existiert, werden von unserem Taschenrechner ignoriert, das heißt sie werden nicht an `display_text` angefügt.

#figure(
  image("../images/calculator/calculator_fsm.png", width: 80%),
  caption: [
    Zustandsautomat eines extrem vereinfachten Taschenrechners
  ],
) <fsm>

Die einzelnen Zustände können wir als Enum repräsentieren. Fügen sie den folgenden Code an den Anfang von _main.zig_ hinzu.

#code(
```zig
// ...

const State = enum {
    start,
    num1,
    num2,
    sym2,
    num3,
    num4,
    E,
};

// Am Anfang befinden wir uns im `start` Zustand
var state: State = .start;
var display_text: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);

// ...
```,
caption: [taschenrechner/src/main.zig])

Für die Verarbeitung der Nutzereingaben definieren wir eine Funktion `addValue`, sowie zwei Hilfsfunktionen `isDigit` und `isSym`. Die Funktion `addValue` bildet den Zustandsautomaten aus @fsm ab und fügt die jeweilige Eingabe zu unserem Textbuffer `display_text` hinzu. Die Funktion `isDigit` prüft ob die Eingabe eine Zahl zwischen Null und Neun ist, während `isSym` überprüft, ob die Eingabe eines der Symbole `+`, `-`, `*` oder `/` darstellt.

#code(
```zig
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
```,
caption: [taschenrechner/src/main.zig])

Die einzige Aufgabe von `addValue` ist es sicher zu stellen, dass der Nutzer nur (nach unseren Maßstäben) korrekte Eingaben tätigen kann. Damit die Funktion jedoch auch Anwendung findet müssen die Aufrufe von `display_text.append()`, innerhalb von `taschenrechner()`, durch einen Aufruf von `addValue()` ersetzt werden ,zum Beispiel `try display_text.append('+');` durch `try addValue('+');`. 

Danach können Sie mit *`zig build run`* die Anwendung neu kompilieren, welche jetzt, je nach Zustand, nur noch bestimmte Eingaben annimmt.

== Ausdruck Evaluieren

Nachdem wir die Regeln für (aus unserer Sicht) korrekte Ausdrücke festgelegt haben, müssen wir diese nun nur noch Evaluieren. Zum Glück bestehen unsere Ausdrücke jeweils nur aus zwei Zahlen. Damit müssen wir uns um die Reihenfolge der Auswertung keine Sorgen machen.

#code(
```zig
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
```,
caption: [taschenrechner/src/main.zig])

Die Funktion `eval()` parsed, falls wir im Endzustand sind, den in `display_text` enthaltenen String in drei Bausteine: die erste Zahl, ein Symbol und die zweite Zahl. Da wir alle eingaben Überprüfen wissen wir beim Parsen, dass der String das erwartete Format hat, wodurch wir beim Aufruf von `next()` den `null`-Fall nicht explizit prüfen müssen. 

Das Ergebnis wird zurück in `display_text` geschrieben. Dadurch können wir mit dem Ergebnis direkt weiterrechnen. Je nachdem, ob das Ergebnis ein Komma enthält, ist der Taschenrechner nach der Berechnung entweder in Zustand `num1` oder `num2`.

Damit das Ergebnis auch berechnet wird, fügen sie einen Aufruf der `eval()` Funktion an das Ende der `taschenrechner()` Funktion hinzu.

#code(
```zig
pub fn taschenrechner() !void {
    // ...

    try eval();
}
```,
caption: [taschenrechner/src/main.zig])

Herzlichen Glückwunsch! Sie haben Ihren ersten, sehr minimalistischen Taschenrechner in Zig programmiert.

== Refactoring

Bevor wir unser kleines Projekt abschließen nutzen wir die Gelegenheit, um den Taschenrechner etwas aufzubessern. Zum einen kann der Code für den Ziffernblock vereinfacht werden. Zum anderen haben die Tasten teilweise unterschiedliche Größen.

Anstelle den Ziffernblock manuell zu definieren, bietet es sich an diesen als zweidimensionales Array abzubilden.

```zig
const pad: [4][4][]const u8 = .{
    .{ "7", "8", "9", "/" },
    .{ "4", "5", "6", "*" },
    .{ "1", "2", "3", "-" },
    .{ "0", ",", "=", "+" },
};
```

Im Anschluss könne wir über die einzelnen Elemente iterieren. Dazu verwenden wir zwei verschachtelte For-Schleifen (eine für jede Dimension des Arrays). Mit der äußeren Schliefen iterieren wir über die Zeilen und mit der Inneren über die einzelnen Elemente der Zeile.

```zig
for (pad, 0..) |row, id1| {
    // Äußere Schleife

    for (row, 0..) |elem, id2| {
        // Innere Schleife
    }
}
```

Jedes Element in dvui, egal ob Box oder Button, wird mit einer Id versehen. Wird die selbe Funktion, zum Beispiel `box()` innerhalb einer Schleife, mehrfach verwendet, so kann dvui dem Element nicht automatisch eine eindeutige Id zuweisen. In solchen Fällen muss die `id_extra` Option beim jeweiligen Funktionsaufruf mit übergeben werden. Aus diesem Grund iterieren wir in den gezeigten For-Schleifen nicht nur über das Array `pad` sondern parallel auch über die Reihe _0, 1, 2, ..._ und verwenden den jeweiligen Index als Extra-Id bei den Funtkionsaufrufen zu `box()` und `button()`.

Die gesamte Funktion sieht dementsprechend wie folgt aus:

#code(
```zig
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
```,
caption: [taschenrechner/src/main.zig])

Die restlichen Optionen werden dazu verwendet, die Elemente zu zentrieren. Mit der `.expand` Option sagen wir dvui, dass die Boxen das gesamte Fenster (entweder nur in der Horizontalen `.horizontal`, in der Vertikalen oder in beide Richtungen `.both`) einnehmen sollen. Die `.gravity_x` Option definiert, dass das jeweilige Element innerhalb eines Containers zentral angeordnet werden soll.

Für die einzelnen Buttons definieren wir, mittels `.min_size_content`, eine einheitliche, minimale Größe von 16.

Damit sieht unsere Anwendung schlussendlich wie folgt aus.

#figure(
  image("../images/calculator/final_calc.png", width: 40%),
  caption: [
    Finaler Zustand des Taschenrechners
  ],
)

== Zusammenfassung

In diesem Kapitel haben Sie gelernt, wie Sie graphische Anwendungen mit dvui entwickeln. Wir haben uns angeschaut, wie ein neues Fenster erzeugt wird und haben dieses mit verschiedenen graphischen Elementen befüllt. Durch die Interaktion mit Buttons haben wir den Zustand unserer Anwendung verändert. Im weiteren haben wir gesehen, wie wir mit der Hilfe von Enums den Zustand unserer Anwendung im Blick behalten und ausgehend von diesem Zustand nur bestimmte Interaktionen zulassen.

Bei unserem Taschenrechner gibt es noch viel Verbesserungsbedarf. Scheuen Sie sich deshalb nicht, mit dem bestehenden Code zu experimentieren. Wie wäre es zum Beispiel mit einer Rücksetzfunktion oder der Möglichkeit negative Zahlen eingeben zu können?
