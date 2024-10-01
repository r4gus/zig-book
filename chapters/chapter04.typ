#import "../tip-box.typ": tip-box, code

= Control Flow

Zig bietet eine ganze Reihe an Kontrollstrukturen, mit denen vorgegeben werden kann, in welcher Reihenfolge die Handlungsschritte eines Algorithmus, beziehungsweise einer Funktion, abzuarbeiten sind. Hierzu zählen bedingte Anweisungen (`if`, `else if`, `else` und `switch`) mit denen verschiedene Zweige, basierend auf einer Bedingung, ausgeführt werden können, Schleifen (`while` und `for`) durch die eine bestimmte Aufgabe mehrere male ausgeführt werde kann und `break`, sowie `continue`, um den Ausführungsfluss an einer anderen Stelle fortzuführen. Zigs `for`-Loops machen es nicht nur einfach über Arrays, Slices und die Elemente von Many-Item-Pointers zu iterieren, sondern sie erlauben auch das parallele Iterieren über mehrere Kollektionen.

== Bedingte Anweisungen

Eine der grundlegendsten Kontrollstrukturen in der strukturierten Programmierung sind bedingte Anweisungen. Hierdurch können einzelne Ausdrücke oder Blöcke, basierend auf einer Bedingung, ausgeführt werden.

Zig bietet zwei Wege, Verzweigungen zu implementieren: If-Statements und Switch-Statements. Während sich If-Statements vor allem für die Überprüfung einer kleinen Menge an Bedingungen eignen, machen es `switch`-Statements einfach, auch auf einer größeren Menge an möglichen Bedingungen zu agieren.

=== If

Die einfachste Form eines If-Statements ist eine bedingte Anweisung, bestehend aus einer Bedingung und einem zugehörigen Code-Abschnitt. Dieser Abschnitt kann entweder eine Block sein, eingegrenzt durch geschweifte Klammern `{}` oder eine Ausdruck (engl. Expression).

Jede einfache bedingte Anweisung beginnt mit dem Schlüsselwort `if`, gefolgt von einer Bedingung in runden Klammern `()`. Die Bedingung muss ein Ausdruck sein, der zu einem `bool` evaluiert, das heißt der Ausdruck ist entweder `true` oder `false`. Nach der Bedingung folgt entweder ein Block oder ein Ausdruck, welcher ausgeführt wird, sollte die Bedingung zu `true` evaluieren.

#code(
```zig
const temp = 31;
if (temp < 20) {
    std.debug.print("Es hat {d} Grad! Pack ne Jacke ein!", .{temp});
}
```
)

Im obigen Beispiel wird geprüft, ob es weniger als 20 Grad Celsius hat. Ist dies der Fall wird eine Nachricht ausgegeben, dass es kalt ist und man eine Jacke einpacken soll. Andernfalls wird der zum `if` gehörende Block nicht ausgeführt.

Oft ist es nötig, entweder einen bestimmten Fall abzudecken oder falls dieser nicht eintritt, unabhängig von weiteren möglichen Fällen, auf eine Alternative zurückzufallen. Hierzu werden Verzweigungen verwendet. Die einfachste Verzweigung ist ein `if`-`else`. Ein `else` ist optional und kann niemals alleine stehen, es muss immer auf ein `if` beziehungsweise `else if` folgen. Es wird ausgeführt, sollte keiner der zuvorkommenden Bedingungen erfüllt worden sein.

#code(
```zig
const temp = 31;
if (temp < 20) {
    std.debug.print("Es hat {d} Grad! Pack ne Jacke ein!", .{temp});
} else {
    std.debug.print("Eigentlich ganz schön heute!", .{});
}
```
)

Das obige Beispiel bedeutet: falls es weniger als 20 Grad Celsius hat gib die erste Nachricht aus, ansonsten gib die zweite Nachricht aus. Dabei ist garantiert, dass einer der beiden Zweige definitiv ausgeführt wird.

Unter der Verwendung von `else if` können beliebig viele Zweige miteinander verkettet werden. Genau wie bei `if` enthält ein `else if` eine Bedingung die erfüllt sein muss, damit der zugehörige Zweig ausgeführt wird. Dabei ist zu betonen, dass bei verketteten, bedingten Anweisung immer nur einer der definierten Fälle zutreffen kann! Die Fälle werden dabei von oben nach unten abgearbeitet.

#code(
```zig
const temp = 31;
if (temp < 20) {
    std.debug.print("Es hat {d} Grad! Pack ne Jacke ein!", .{temp});
} else if (temp > 30) { 
    std.debug.print("Wow {d} Grad! Pack die Badehose ein!", .{temp});
} else {
    std.debug.print("Eigentlich ganz schön heute!", .{});
}
```,
caption: [chapter04/if.zig])

Das obige Beispiel liest sich wie folgt. Hat es weniger als 20 Grad Celsius so wird der Nutzer aufgefordert eine Jacke einzupacken. Hat es mehr als 30 Grad Celsius, so wird er aufgefordert eine Badehose einzupacken. Ansonsten, falls die Temperatur zwischen 20 und 30 Grad liegt, wird der `else`-Block ausgeführt.

`if`, `else if` und `else` können auch dazu verwendet werden, basierend auf einer oder mehreren Bedingungen, eine Variable zu initialisieren. Hierzu wird eine If-Expression verwendet. Der Unterschied ist, dass anstelle eines Blocks ein Ausdruck auf die jeweilige Bedinung bzw. `else` folgt. Wie alle anderen Ausdrücke auch, müssen If-Expressions mit einem Semilkolon `;` abgeschlossen werden.

#code(
```zig
const nachricht =
    if (temp < 20)
        "Pack ne Jacke ein!"
    else if (temp > 30)
        "Pack die Badehose ein!"
    else
        "Eigentlich ganz schön heute!";

    std.debug.print(nachricht, .{});
```,
caption: [chapter04/if.zig])

In diesem Beispiel wird je nachdem welche Bedingung wahr ist, die Konstante `nachricht` mit dem entsprechenden String initialisiert. Alle Zweige müssen hierfür einen Wert des selben Typs zurückgeben, das heißt der Rückgabetyp der If-Expression wird durch die Rückgabewerte aller zweige bestimmt. Außerdem ist in diesem Fall das `else` nicht optional, da es sonst zu Fällen kommen kann, in denen `nachricht` gar kein Wert zugewiesen wird.

Sollte für bestimmte Fälle kein vernünftiger Rückgabewert angegeben werde können, so kann innerhalb einer If-Expression auch `null` verwendet werden. In diesem Fall ist der Rückgabewert des Ausdrucks ein Optional.

#code(
```zig
const nachricht: ?[]const u8 =
    if (temp < 20)
        "Pack ne Jacke ein!"
    else if (temp > 30)
        "Pack die Badehose ein!"
    else
        null;
```
)

=== If mit Errors

Mit `if` kann auch auf Fehler geprüft werden. Hierfür muss die Bedingung eines If-Statements ein Ausdruck sein, der zu einem Error-Typ evaluiert (zum Beispiel `anyerror!u32`). Das `else` ist bei der Prüfung von Fehlern nicht optional und muss immer verwendet werden.

#code(
```zig
test "error capture #1" {
    const a: anyerror!u32 = 7;
    if (a) |value| {
        try std.testing.expect(value == 7);
    } else |err| {
        _ = err;
        unreachable;
    }
}
```,
caption: [chapter04/if.zig])

Die durch `||` eingerahmten Variablen hinter dem `if` und `else` werden als Capture bezeichnet. Sie "fangen" jeweils den zum Zweig gehörenden Wert des Error-Typs. 

Evaluiert der Ausdruck (im obigen Fall ist dies lediglich die Variable `a`) zu einem Error, so wird der `else`-Zweig betreten und der Error wird an `err` gebunden. Andernfalls wird der If-Zweig betreten und der Wert (in diesem Beispiel `7` vom Typ `u32`) wird an `value` gebunden. Die Namen der Captures sind, nach den Syntax-Regeln für Variablen, frei wählbar. Wird ein Capture nicht benötigt, so kann anstelle eines Namen auch ein `_` verwendet werden.

Im Kontrast zu `catch` entpackt ein `if` den Wert eines Ausdrucks nicht automatisch, sondern bindet ihn lediglich an ein Capture. Das Verhalten von `catch` lässt sich jedoch auch mit `if` reproduzieren:

#code(
```zig
test "error capture #2" {
    const a: anyerror!u32 = 7;
    const value = if (a) |value| value else |_| {
        unreachable;
    };
    try std.testing.expect(value == 7);
}
```,
caption: [chapter04/if.zig])

#tip-box([
    Das im obigen Beispiel zu sehende `unreachable` hilft bei der Code-Optimierung. Es sagt aus, dass der Zweig nicht erreicht werden kann. Wenn Sie `unreachable` verwenden müssen Sie sich absolut sicher sein, dass dies auch zutrifft! Für den gegebenen Fall ist dies trivial, da `a` immer den Wert `7` hält.
])

=== If mit Optionals

Analog zu Errors kann mit `if` auch auf `null` getestet werden. Während bei Errors der `else`-Zweig Pflicht ist, kann dieser für Optionals auch weggelassen werden.

#code(
```zig
test "optionals capture #1" {
    const a: ?u32 = 7;
    if (a) |value| {
        try std.testing.expect(value == 7);
    } else {
        // Mach etwas falls `a == null`
    }
}
```,
caption: [chapter04/if.zig])

Evaluiert der gegebene Ausdruck (im obigen Beispiel die Variable `a`) zu `null`, so wird der `else`-Zweig ausgeführt, falls dieser vorhanden ist. Andernfalls wird der If-Zweig ausgeführt und der entpackte Wert an den Capture `value` gebunden.

=== Pointer-Capture

Durch Pointer-Capture können, bei der Verwendung von `if` mit Errors oder Optionals, die Werte einer Variable modifiziert werden. Dabei ist das Capture ein Zeiger auf die ursprüngliche Variable.

#code(
```zig
test "optionals with pointer-capture #1" {
    var a: ?u32 = 7;
    if (a) |*value| {
        try std.testing.expect(value.* == 7);
        value.* += 1;
    }
    try std.testing.expect(a == 8);
}
```,
caption: [chapter04/if.zig])

=== Switch

Während bei If-Statements der Zweig basierend auf einem Boolean (`true`) ausgewählt wird, verwenden Switch-Statements einen Musterabgleich (engl. Pattern-Matching). Hierfür wird ein Wert, mit einem oder mehreren Werten des selben Typs, verglichen. So lässt sich zum Beispiel überprüfen, ob ein Integer in einem bestimmten Wertebereich liegt.

Jedes Switch-Statement beginnt mit dem Schlüsselwort `switch` gefolgt von einem Ausdruck in runden Klammern. Der Wert dieses Ausdrucks wird mit einem oder mehreren Mustern verglichen, die jeweils einen Zweig darstellen. Die Zweige werden in geschweiften Klammern zusammengefasst und bestehen aus `Muster => {}` oder `Muster => Ausdruck`, jeweils getrennt durch ein Komma.

#code(
```zig
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
```,
caption: [chapter04/switch.zig])

Wichtig ist, dass bei einem `switch` alle möglichen Fälle abgedeckt sein müssen. Ist dies nicht möglich oder zu aufwendig kann ein `else`-Zweig verwendet werden, der alle bisher nicht abgedeckten Möglichkeiten abdeckt. Sollten nicht alle möglichen Fälle abgedeckt werden, so resultiert dies in einem Fehler während des Kompilierens.

#tip-box([
    Jeder Fall eines `switch` steht für sich alleine, das heißt es muss nicht explizit aus dem `switch` "ausgebrochen" werden. Dies steht im Kontrast zu Sprachen, wie etwa C, bei denen, von oben nach unten, durch die einzelnen Fälle durchgefallen werden kann, das heißt solange nicht das Ende des `switch` erreicht ist, wird in C der nächste Switch-Case ausgeführt.
])

Genau wie bei `else` kann auch ein `switch` als Ausdruck verwendet werden.

#code(
```zig
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
```,
caption: [chapter04/switch.zig])

Genau wie alle anderen Ausdrücke auch, wird `switch` mit einem Semilkolon abgeschlossen. Bei der Verwendung eines `switch` als Ausdruck ist wichtig, dass alle Zweige einen Rückgabewert besitzen und dass die Rückgabewerte aller Zweige vom selben Typ ist, bzw. in einen gemeinsamen Typ konvertiert werden kann. Dies schließt die Verwendung von `null` mit ein.

Mit Switch-Cases kann ebenfalls überprüft werden, ob ein Wert in einem bestimmten Wertebereich liegt. Wertebereiche werden durch einen Start- und Endwert eingegrenzt, der entweder inklusive (`start...end`) oder exklusive (`start..end`) angegeben werden kann.

#code(
```zig
fn encode(out: anytype, head: u8, v: u64) !void {
    switch (v) {
        0x00...0x17 => {
            try out.writeByte(head | @as(u8, @intCast(v)));
        },
        0x18...0xff => {
            try out.writeByte(head | 24);
            try out.writeByte(@as(u8, @intCast(v)));
        },
        0x0100...0xffff => try cbor.encode_2(out, head, v),
        0x00010000...0xffffffff => try cbor.encode_4(out, head, v),
        0x0000000100000000...0xffffffffffffffff => try cbor.encode_8(out, head, v),
    }
}
```,
caption: [https://github.com/r4gus/zbor/blob/master/src/build.zig])

Das obige Beispiel ist Teil eines CBOR-Parsers #footnote[https://github.com/r4gus/zbor], implementiert in Zig. Der Code ist dafür verantwortlich, einen Wert `v` so klein wie möglich zu kodieren. Hierfür wird, anhand des Wertebereichs, geprüft, wie viele Bytes zur Kodierung benötigt werden. Die Wertebereiche werden in diesem Beispiel inklusive angegeben. Liegt `v` zum Beispiel zwischen 0 und 23 (beide Werte eingeschlossen), so wird exakt ein Bytes zur Kodierung verwendet.

== While-Schleifen

While-Schleifen führen eine Code-Block wiederholt aus, bis eine Bedingung zu `false` evaluiert.

== For-Schleifen

Es kann äußerst nützlich sein über den Inhalt eines Arrays oder Slices zu iterieren. Eine Möglichkeit dies zu tun ist mit Hilfe einer For-Schleife.

#code(
```zig 
const names = [_][]const u8{ "David", "Franziska", "Sarah" };

for (names) |name| {
    std.log.info("{s}", .{name});
}
```,
caption: [chapter02/loop.zig])

Eine for-Schleife beginnt mit dem Schlüsselwort `for`, gefolgt von einer Sequenz, über die iteriert werden soll, in runden Klammern. Danach wird ein Bezeichner zwischen zwei `| |` angegeben. Dem Bezeichner wird für jede Iteration der aktuelle Wert zugewiesen, d.h. für das obige Beispiel wird im ersten Schleifendurchlauf `name` der Wert `"David"` zugewiesen, im zweiten Durchlauf `"Franziska"` und so weiter. Nachdem über alle Elemente iteriert wurde, wird automatisch aus der Schleife ausgebrochen.

Eine Besonderheit von Zig ist, dass innerhalb einer for-Schleife simultan über mehrere Sequenzen iteriert werden kann.

#code(
```zig
for (names, 0..) |name, i| {
    std.log.info("{s} ({d})", .{ name, i });
}
```
)

Die Sequenzen werden, getrennt durch ein Komma, innerhalb der runden Klammer angegeben. Selbes gilt für die Bezeichner, an die die einzelnen Werte der Sequenzen gebunden werden. Im obigen Beispiel wird als zweite Sequenz `0..` angegeben, d.h. eine Sequenz von Ganzzahlen beginnend bei $0$. Zig sorgt dabei automatisch dafür, dass `names` und `0..` über die selbe Länge verfügen, indem das Ende von `0..` automatisch bestimmt wird, d.h. für das gegebene Beispiel ist `0..` äquivalent zu `0..3`.

Sollten Sie über mehrere Arrays bzw. Slices gleichzeitig iterieren, so müssen sie sicherstellen, dass alle die selbe Länge besitzen!

#code(
```zig
const dishes = [_][]const u8{ "Apfelstrudel", "Pasta", "Quiche" };

for (names, dishes) |name, dish| {
    std.log.info("{s} likes {s}", .{ name, dish });
}
```
)

Mit dem Schlüsselwort `break` kann aus einer umschließenden Schleife ausgebrochen werden, d.h. das Programm wird unter der Schleife fortgeführt.

#code(
```zig
for (1..5) |i| {
    std.log.info("{d}", .{i});
    if (i == 2) break;
}
```
)

Mit dem Schlüsselwort `continue` können sie den restlichen Körper der Schleife überspringen und mit der nächsten Iteration beginnen. Sollten `continue` in der letzten Iteration der Schleife ausgeführt werden, so wird aus dieser ausgebrochen.

#code(
```zig
for (1..5) |i| {
    if (i == 2) continue;
    std.log.info("{d}", .{i});
}
```
)

Schleifen können auch geschachtelt werden. Wenn Sie innerhalb einer der inneren Schleifen, aus einer der Äußeren ausbrechen wollen, müssen Sie sogenannte Label verwenden, mit der sie einer bestimmten Schleife einen Namen geben können. Labels kommen vor dem `for` Schlüsselwort und enden immer mit einem `:`. Sie können sowohl mit `break` als auch `continue` verwendet werden.

#code(
```zig
outer: for (names) |name| {
    for (dishes) |dish| {
        std.log.info("({s}, {s})", .{ name, dish });
        // Da wir an dieser stelle aus der äußeren Schleife ausbrechen
        // ist nur eine Ausgabe auf der Kommandozeile zu sehen.
        break :outer;
    }
}
```
)

Zig erlaubt auch die Verwendung von for-Loops in Ausdrücken.

#code(
```zig
const pname = outer: for (names) |name| {
    if (name.len > 0 and (name[0] == 'p' or name[0] == 'P'))
        break :outer name;
} else blk: {
    break :blk "no name starts with p!";
};
std.log.info("found: {s}", .{pname});
```
)

In diesem Beispiel suchen wir nach einem Namen der mit dem Buchstaben P bzw. p beginnt. Sollte aus der Schleife mit `break` ausgebrochen werden, so wird der `else` Block nicht ausgeführt. Da `names` keinen solchen Namen beinhaltet wird der `else` Block aufgerufen und der String `"no name starts with p!"` der Konstanten `pname` zugewiesen. 

Neben Schleifen können auch `if`/`else` Blöcken Label zugewiesen werden. Dies erlaubt es, mittels `break`, Werte aus dem Block heraus zu reichen, wie oben zu sehen ist.

Sie können das Beispiel mit *`zig build-exe chapter02/loop.zig && ./loop`* compilieren und ausführen.
