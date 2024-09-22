#import "../tip-box.typ": tip-box
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

= Standard Typen

Zig ist eine kompilierte Sprache, d.h. sie wird, bevor der Programmcode ausgeführt werden kann, in eine Sprache übersetzt die vom Prozessor verstanden wird. Die Übersetzungsarbeit übernimmt dabei der Compiler.

TBD

#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Typ*], [*Beschreibung*], [*Beispielwerte*],
  ),
  [`i8`, `u65`],
  [Vorzeichen(un)behaftete Ganzzahlen mit der angegebenen Bitbreite (von 0 bis $2^16 - 1$).],
  [`0x32`, `-1`],

  [`usize`, `isize`],
  [Vorzeichen(un)behaftete Ganzzahlen deren Bitbreite mit der der Architektur übereinstimmt, d.h. auf `x86_64` wäre `usize` gleichbedeutend mit `u64`.],
  [`0xcafe_babe`],
)

== Zeiger (Pointer)

Zig unterscheidet zwischen zwei Arten von Zeigern, _single-item_ und _many-item_ Pointer.

Ein single-item Pointer `*T` zeigt auf exakt einen Wert im Speicher und kann mit der Syntax `ptr.*` dereferenziert werden. Mit Hilfe des Address-of-Operators `&` kann ein single-item Pointer bezogen werden.

```zig
// Definiere eine Variable vom Typ u8
var v: u8 = 128;
// Beziehe einen Zeiger auf `v`
const v_ptr = &v;
// Dereferenziere den Zeiger `v_ptr` und addiere 1 zu `v`
v.* += 1;
```

Ein multi-item Pointer `[*]T` zeigt auf eine lineare Sequenz an Werten im Speicher mit unbekannter Länge. Der Zeiger eines Slice (`.ptr`) ist ein multi-item Pointer. Allgemein teilen Slices und multi-item Pointer die selbe Index- und Slice-Syntax.

- `ptr[i]`
- `ptr[start..end]`
- `ptr[start..]`

Genau wie C erlaubt auch Zig Zeigerarithmetik auf multi-item Pointer.

```zig
// chapter02/pointer.zig
var array = [_]i32{ 1, 2, 3, 4 };

var array_ptr = array[0..].ptr;

std.log.info("{d}", .{array_ptr[0]});
array_ptr += 1;
std.log.info("{d}", .{array_ptr[0]});
```

Nach dem Compilieren mit *`zig build-exe chapter02/pointer.zig`* können wir die Beispiel Anwendung ausführen und sehen, dass die ersten beiden Zahlen von `array` ausgegeben werden, obwohl wir den selben Index für `array_ptr` verwenden. Grund dafür ist, dass wir den Zeiger selbst, zwischen dem ersten und zweiten Aufruf von `std.log.info()`, inkrementiert haben.

```bash
$ ./pointer 
info: 1
info: 2
```

Ein weit verbreitetes Konzept in C sind `NULL`-terminierte Strings, d.h. ein `0`-Byte wird hinter den letzten Character eines Strings geschrieben und markiert so dessen Ende. Zig bietet etwas sehr ähnliches, nämlich sentinel-terminated Pointer.

Ein sentinel-terminated Pointer wird durch einen Typ `[*:x]T` beschrieben, wobei `x` ein Wert vom Typ `T` ist und den Sentinel darstellt, der das Ende einer Sequenz markiert. Analog zu einem `NULL`-terminierten String vom Typ `char*` in C, schreibt man in Zig `[*:0]u8`.

#tip-box([
    Im Allgemeinen werden in Zig Slices, gegenüber sentinel-terminated Pointern, präferiert. Der Grund hierfür ist, dass Slices über Bounds-Checking verfügen und so gängige Speicherfehler abgefangen werden können. Es gibt jedoch auch Situationen, in denen many-item Pointer bzw. sentinel-terminated Pointer explizit benötigt werden, z.B. beim Arbeiten mit C Code. Auf die Interoperabilität zwischen Zig und C wird in einem späteren Kapitel noch näher eingegangen.
])

== Container

Jedes syntaktische Konstruct in Zig, welches als Namensraum dient und Variablen- oder Funktionsdeklaraionen umschließt, wird als Container bezeichnet. Weiterhin können Container selbst Typdeklarationen sein, welche instantiiert werden können. Dazu zählen `struct`s, `enum`s, `union`s und sogar Sourcedateien mit der Dateiendung _.zig_.

Ein Merkmal welches Container von Blöcken unterscheidet ist, dass Container keine Ausdrücke enthalten, obwohl sowohl Container als auch Blöcke, mit der Ausnahme von Sourcedateien, in geschweifte Klammern (`{}`) gefasst werden.

#tip-box([
    In Zig ist die Definition von Structs, Enums und Unions ein Ausdruck, d.h. Definitionen müssen mit einem Semikolon `;` abgeschlossen werden (z.B. `struct {};`).
])

=== Struct

Ein Struct erlaubt die Definition eines neuen Datentyp der eine Menge an Werten, von einem bestimmten Typ, zusammenfasst. Structs werden mit dem `struct` Schlüsselwort deklariert. Der Inhalt eines Structs wird dabei in geschweifte Klammern gefasst. Innerhalb der geschweiften Klammern wird jeder Wert, den ein Struct umschließt, durch einen Bezeichner bzw. Namen und einen Typen, getrennt durch ein `:`, deklariert. Diese Kombination aus Name und Typ wird als Feld (engl. field) bezeichnet. Nach jedem Feld folgt ein Komma (`,`), welches das Feld vom danach folgenden Feld trennt. Neben Feldern können Structs auch Methoden, Funktionen, Konstanten und Variablen enthalten.

```zig
// chapter02/color.zig

// Das Struct wird der Konstante `RgbColor` zugewiesen. 
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
        // ...
    }
};
```

Mit Hilfe der Funktion `@This()` kann auf den umschließenden Kontext, im obigen beispiel das Struct, welches an `RgbColor` #footnote[Die gängige Konvention ist, dass Typbezeichner Camel-Case verwenden, d.h. ein zusammengeschriebenes Wort beginnend mit einem Großbuchstaben.] gebunden wird, zugegriffen werden.

Funktionen im allgemeinen Sinn, die innerhalb eines Structs definiert sind, werden in Methoden und (Struct-)Funktionen unterteilt. Der Unterschied zwischen beiden ist dabei subtil. Der erste Parameter einer Methode besitzt als Typ immer das Struct selbst, z.B. `@This()`, `*@This()` oder `*const @This()`. Alternativ zu `@This()` kann auch direkt der Name verwendet werden, z.B. `pub fn getRed(self: *const RgbColor) u8 { ... }`. Methoden können direkt auf einer Instanz aufgerufen werden. Funktionen auf der anderen Seite haben als ersten Parameter nicht den Typ des Structs und werden über den Namen der Funktion aufgerufen, z.B. `RgbColor.foo()`.

Konstanten innerhalb von Structs können dazu verwendet werden um Werte, wie etwa die Länge eines kryptografischen Schlüssels oder wie oben zu sehen, gängige Farben, die im Bezug zu dem gegeben Struct stehen im selben Scope zu deklarieren.

Um ein Struct nach seiner Definition zu verwenden, muss dieses instanziiert werden, indem für jedes Feld ein konkreter Wert angegeben wird. Das Instanziieren erfolgt indem der Name des Struct, gefolgt von geschweiften Klammern, angegeben wird. Innerhalb der Geschweiften Klammern wird jedem Feld ein Wert zugewiesen. Alternativ kann, wie oben zu sehen ist, bei der Definition eines Structs jedem Feld ein Standardwert zugewiesen werden, der automatisch übernommen wird, sollte beim Instanziieren des Structs kein Wert für das Feld angegeben werden.

```zig
// Die Zuweisung der Felder muss nicht in der selben Reihenfolge
// erfolgen, in der die Felder deklariert wurden.
const red = RgbColor{ .r = 255, .b = 0, .g = 0 };
// Angabe des Grün-Werts. Für die restlichen Felder wird der
// Standardwert `0` übernommen.
var green = RgbColor{ .g = 255 };
// Zugriff auf die Konstante `BLUE` definiert in `RgbColor`
const blue = RgbColor.BLUE;
```

Um auf ein bestimmtes Feld zuzugreifen wird Punktnotation verwendet. Um zum Beispiel auf den Rot-Wert der Konstante `red` zuzugreifen wird `red.r` verwendet. Auf die selbe Weise kann auch auf Methoden zugegriffen werden (z.B. `red.add(green)`). Im Fall von Variablen erfolgt eine (Neu-)Zuweisung von Feldern ebenfalls über die Punktnotation (z.B. `green.g = 128;`).

```zig
// Wir addieren die Werte zweier Farben.
const new_color = red.add(green);
```

#tip-box([
    In Zig sind alle Sturcts anonym. Ihr Name ist dementsprechend abhängig von ihrer Umgebung:
    - Ist das Struct der initialisierende Ausdruck einer variable, so wird es nach der Variable benannt.
    - Ist das Struct Teil eines `return` Ausdrucks, so wird es nach der Funktion benannt, von welcher es zurückgegeben wird.
    - Andernfalls wird dem Struct ein Name nach dem Muster `filename.funcname.__struct_ID` zugewiesen.
])

==== init Pattern

Sobald Sie mit Feldern arbeiten, deren Werte dynamisch alloziert werden, stellt sich schnell die Frage wie und von wem der allozierte Speicher verwaltete werden soll. Verwalten kann dabei mehrere Dinge bedeuten:

- Das initiale Allozieren von Speicher, für bestimmte Felder, beim instanziieren eines Structs.
- Die Freigabe des Speichers, sobald das Struct nicht mehr benötigt wird.
- Die Neuzuweisung eines Feldes vom Typ Single-Item-/Multi-Item-Pointer.

Zwar können all diese Aufgaben dem Nutzer des entsprechenden Struct-Datentyps auferlegt werden #footnote[In den meisten Fällen sind das wohl Sie selbst.], je nach Anzahl der Zeiger-Felder kann dies jedoch extrem mühsam werden. Außerdem laufen Nutzer Gefahr, den Speicher nicht korrekt zu managen und so Speicherfehler, wie etwa Memory-Leaks bei denen Speicher nicht mehr freigegeben wird, in ihren Code einzubauen.

Aus diesem Grund hat sich in Zig ein Konzept durchgesetzt, bei dem der dynamisch allozierte Speicher von einer Struct-Instanz selbst verwaltet wird. Structs die den Speicher ihrer Felder managen, verfügen meist über eine `init()` oder `new()` Funktion, die ein Objekt vom Typ `std.mem.Allocator` übergeben bekommt und das Struct initialisiert bzw. instanziiert, sowie eine `deinit()` Funktion, die den verwalteten Speicher wieder freigibt. Optional kann ein Struct über Setter-Funktionen für Felder verfügen, die vor der Neuzuweisung das alte Objekt deallozieren.

```zig
// chapter02/managed.zig
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
```

Der Test für den obige Code kann mit *`zig test chapter02/managed.zig`* ausgeführt werden.

```zig
const allocator = std.testing.allocator;

var s = String.init(allocator);
// Sie können die untere Zeile auskommentieren um zu sehen, wie
// Sie einen Memory-Leak provozieren.
defer s.deinit();

try s.set("Hello, World!");
try std.testing.expectEqualStrings("Hello, World!", s.get().?);

try s.set("Ich liebe Kryptografie");
try std.testing.expectEqualStrings("Ich liebe Kryptografie", s.get().?);
```

Innerhalb des Tests weisen wir die mit `init` erzeugte String-Instanz der Variable `s` zu. Direkt danach platzieren wir einen `defer` Ausdruck der dafür sorgt, dass `deinit` am Ende des Blocks aufgerufen wird. 

#tip-box([
    Wenn Sie wissen, dass sie ein Objekt im selben Block deinitialisiern wollen, sollten Sie sich grundsätzlich angewöhnen dies mit einem `defer`, direkt nach der Instanziierung des Objekts, zu machen. So vergessen Sie nicht, ihre Objekte auch wieder freizugeben.
])

Danach weisen wir `s` mittels der Setter-Funktion `set()` den String `"Hello, World!"` zu und überprüfen im Anschluss mit `expectEqualStrings()`, unter Verwendung des Getters `get()`, ob der String auch korrekt zugewiesen wurde. Dies wiederholen wir mit einem zweiten String `"Ich liebe Kryptografie"` um zu überprüfen, dass die Deallokation des alten, von `s` gemanagten, Strings statt findet, bevor der neue String zugewiesen wird. 

Eine Besonderheit des `std.testing.allocator` ist, dass beim ausführen eines Tests, nicht freigegebener Speicher automatisch, als Fehler, an den Aufrufer kommuniziert wird. Dadurch testen wir nicht nur das `set()` den gemanagten String neu zuweist, sonder auch den alten String freigibt.

==== Anonyme Struct-Literale

Zig erlaubt es den Struct-Typ eines Literals wegzulassen. In diesem Fall wird der Typ des Structs abgeleitet. Bei der Konvertierung zu einem anderen Typen, Instanziiert das Literal direkt die _Result-Location_.

```zig
const Point = struct { x: i32, y: i32 };
const pt: Point = .{
    .x = 16,
    .y = 16,
};
```

==== Result-Location

Ein Konzept, das nicht nur Structs betrifft, auf welches ich an dieser Stelle trotzdem eingehen weil es die Instanziierung von Structs betrifft, ist das Konzept von _Result-Locations_.

Bestimmten Ausdrücken in Zig wird eine sogenannte Result-Location zugewiesen, d.h. ein Zeiger auf einen Speicherbereich, in welchen das Ergebnis des Ausdrucks direkt geschrieben werden muss. Dies verhindert die Erzeugung von Kopien des Ergebnisses während der Initialisierung von Datenstrukturen. In vielen Fällen hat dies keine praktischen Auswirkungen. 

Anders sieht es u.a. bei der Instanziierung von Structs mithilfe eines Literals aus. Angenommen der Ausdruck `.{ .a = x, .b = y }` hat die Result-Location `ptr`. In diesem Fall hätte der Ausdruck `x` die Result-Location `&ptr.a` und `y` die Result-Location `&ptr.b`. Ohne das Konzept von Result-Locations würde der Ausdruck ein temporäres Struct auf dem Stack anlegen, um dieses im Anschluss an die Zieladresse zu kopieren. Anders ausgedrückt, Zig zerlegt den Ausdruck `foo = .{ .a = x, .b = y }` in zwei gesonderte Ausdrücke `foo.a = x;` und `foo.b = y;`.

Ein klassisches Beispiel bei dem dies Zum Verhängnis werden kann, ist beim Tauschen von Feldern eines Sturcts oder Arrays.

```zig
var arr: [2]u32 = .{ 1, 2 };
arr = .{ arr[1], arr[0] };
```

Da keine temporären Wert für `arr[0]` und `arr[1]` gespeichert werden sieht der obige Ausdruck erst einem O.K. aus, führt jedoch zu einem unerwarteten Resultate, sollte man sich dem Konzept von Result-Location nicht bewusst sein. Die zweite Zeile ist nämlich äquivalent zu folgendem:

```zig
arr[0] = arr[1];
arr[1] = arr[0];
```

Zuerst wird das erste Element von `arr` mit dem Wert `2` überschrieben, welcher sich an Index `1` befindet. Danach wird das zweite Element mit dem Wert des Ersten überschrieben. Schlussendlich ist der Inhalt von Array äquivalent zu `.{ 2, 2}`.

Die Folgende Tabelle listet Ausdrücke, für die das Konzept von Result-Locations zutrifft.

#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Ausdruck*], [*Result Location*], [*Result Location für Teilausdruck*],
  ),
  [`const val: T = x`],
  [keine],
  [`x` hat die Result-Location `&val`],

  [`var val: T = x`],
  [keine],
  [`x` hat die Result-Location `&val`],

  [`val = x`],
  [keine],
  [`x` hat die Result-Location `&val`],

  [`@as(T, x)`],
  [ptr],
  [keine],

  [`&x`],
  [ptr],
  [keine],

  [`f(x)`],
  [ptr],
  [keine],

  [`.{x}`],
  [ptr],
  [`x` hat die Result-Location `&ptr[0]`],

  [`.{ .a = x }`],
  [ptr],
  [`x` hat die Result-Location `&ptr.a`],

  [`T{x}`],
  [ptr],
  [keine (Typinitialisierer propagieren keine Result-Locations!)],

  [`T{ .a = x }`],
  [ptr],
  [keine (Typinitialisierer propagieren keine Result-Locations!)],

  [`@Type(x)`],
  [ptr],
  [keine],

  [`@typeInfo(x)`],
  [ptr],
  [keine],

  [`x << y`],
  [ptr],
  [keine],
)

Wie aus der Tabelle zu entnehmen ist, macht es in Bezug auf Structs, sowie Arrays, einen Unterschied ob während der Initialisierung ein anonymes Struct-Literal `.{ .a = x }` angegeben wird oder nicht `T{ .a = x }`, da nur bei anonymen Struct-Literalen die Result-Location zu den Teilausdrücken propagiert.

==== Tuples

Anonyme Struct-Literale ohne Feldnamen werden als _Tupel_ bezeichnet. Die Felder eines Tupel werden automatisch durchnummeriert, wobei dem ersten Feld der Index $0$ zugewiesen wird, dem zweiten Feld der Index $1$ und so weiter.

```zig
const v = .{
    @as(u16, 0xcafe),
    "dave",
    true,
};
```

Es gibt zwei Möglichkeiten auf die Felder eines Tupel zuzugreifen:

1. Mithilfe der Dot-Notation `.`, wobei der Feldname in eine `@""` gefasst werden muss #footnote[Namen innerhalb von `@""` können immer als Identifier verwendet werden, was Zahlen und Strings mit Leerzeichen einschließt!], z.B. `v.@"1"`.
2. Alternativ kann auch ein Index in `[]` angegeben werden (z.B. `v[1]`), wobei der Index zu Compilezeit bekannt sein muss.

=== Enum

Ein weiterer Typ der in keiner Programmiersprache fehlen darf sind Enums. Enums erlauben die Definition einer Menge an Werten, die intern durch einen numerischen Wert gedeckt sind.

```zig
const IPType = enum {
    IPv4,
    IPv6,
};
```

Anders ausgedrückt, Enums erlauben es einer Menge an Zahlen einen Namen zuzuordnen, die in einem bestimmten Kontext Sinn ergeben.

Um einer Variable einen Enum-Wert zuzuweisen kann Punktnotation verwendet werden.

```zig
const ipv4 = IPType.IPv4;
```

Normalerweise wird der, zu jedem Enum-Wert gehörende, numerische Wert, sowie dessen Typ, von Zig festgelegt. Sollte ein bestimmter Zahlentyp benötigt werden, kann dieser in runden Klammern, hinter dem `enum` Schlüsselwort, angegeben werden.

```zig
// Ein Enum gedeckt durch ein `u8`
const IPType = enum(u8) {
    IPv4,
    IPv6,
};
```

Weiterhin kann jedem Enum-Wert explizit ein numerischer Typ zugewiesen werden.

```zig
const IPType = enum(u8) {
    IPv4 = 4,
    IPv6 = 6,
};
```

Dabei muss nicht jedem Wert explizit ein numerischer Wert zugewiesen werden. Für nicht zugewiesene Werte legt Zig automatisch einen numerischen Wert fest.

Genau wie Stucts können auch Enums Methoden enthalten. Dabei gelten die selben Regeln, d.h. der erste Parameter muss den Typ des umschließenden (e.g. `IPType`) enthalten.

```zig
const IPType = enum(u8) {
    IPv4 = 4,
    IPv6 = 6,

    pub fn isIPv4(self: @This()) bool {
        // Der Typ muss nicht immer explizit angegeben werden. In diesem Beispiel
        // reicht es einen Punkt (`.`) gefolgt vom Namen des Enum-Werts anzugeben.
        // Dies wird als Enum-Literal bezeichnet.
        return self == .IPv4;
    }
};
```

Enums können in `switch` Statements verwendet werden. Wie auch bei anderen Typen muss dabei darauf geachtet werden, dass alle Fälle abgedeckt werden oder alternativ ein `else` Zweig verwendet wird.

```zig
const ip = IPType.IPv4;
const desc = switch (ip) {
    IPType.IPv4 => "a IPv4 address",
    IPType.IPv6 => "a IPv6 address",
};
std.log.info("{s}", .{desc});
```

Mit `@intFromEnum` kann ein Enum-Wert in seine numerische Repräsentation umgewandelt werden. Diese Operation kann nicht fehlschlagen, da jeder Enum-Wert von einer Zahl gedeckt wird.

```zig
std.debug.assert(@intFromEnum(IPType.IPv4) == 4);
```

Die Inverse Funktion zu `@intFromEnum` ist `@enumFromInt`. Mit ihr kann ein Integer in einen Enum-Wert umgewandelt werden. Da nicht jede Zahl mit einem Enum-Wert in Beziehung stehen muss kann diese Operation fehlschlagen.

```zig
std.debug.assert(@as(IPType, @enumFromInt(4)) == IPType.IPv4);
```

Enums haben einen besonderen Bezug zu Unions, welche wir uns als nächstes genauer anschauen werden.

=== Union

Unions sind nutzerdefinierte Typen die in sich mehrere verschiedene Typen vereinen können. Die verschiedenen Typen, die ein Union in sich vereint, werden als Liste an Feldern definiert. Zu einem bestimmten Zeitpunkt kann für eine Instanz immer nur ein Feld aktiv sein.

```zig
const IPAddr = union {
    IPv4: [4]u8,
    IPv6: [8]u16,
};

// Die Variable `ipv4` bindet einen Wert vom Typ `IPAddr` wobei
// das Feld `IPv4` des Unions aktiv ist.
const ipv4 = IPAddr{ .IPv4 = .{127, 0, 0, 1} };
```

Der Speicher, den ein Union benötigt, ist abhängig von dem Union-Feld mit dem größten Speicherbedarf. Im obigen Beispiel benötigt das `IPv4`-Feld $4 * 8 "Bit" = 32 "Bit" = 4 "Byte"$ und das `IPv6`-Feld benötigt $8 * 16 "Bit" = 128 "Bit" = 16 "Byte"$. Demnach benötigt jede Instanz von `IPAddr` immer 16 Byte an Speicher, unabhängig davon welches Feld aktiv ist.

Um Unions in `switch`-Statements verwenden zu können, müssen sogenannte Tagged-Unions verwendet werden. Diese können definiert werden, indem nach dem `union` Schlüsselwort, in runden Klammern, ein Enum angegeben wird, dessen Felder sich mit den Feldern des Unions überschneiden.

```zig
const IPAddr = union(IPType) {
    IPv4: [4]u8,
    IPv6: [8]u16,
};

const ipv4 = IPAddr{ .IPv4 = .{127, 0, 0, 1} };

switch (ipv4) {
    .IPv4 => |v| std.log.info("{d}.{d}.{d}.{d}", .{v[0], v[1], v[2], v[3]}),
    .IPv6 => |_| std.log.info("a IPv6 address", .{});
}
```

Innerhalb eines `switch`-Statements kann nach dem `=>` eine Variable innerhalb von `| |` angegeben werden, an welche der Wert der Union-Instanz gebunden werden soll. Wird der Wert nicht benötigt, so kann anstelle einer Variable auch ein `_` angegeben werden.

Soll der Wert eines Unions innerhalb eines `switch`-Statements modifiziert werden, so muss der Variable, an welche der Wert des Unions gebunden werden soll, ein `*` vorangestellt werden.

```zig
switch (ipv4) {
    .IPv4 => |*v| v.* = .{ 192, 168, 13, 128 },
    .IPv6 => {}; // Eine weitere Möglichkeit diesen Zweig zu ignorieren
}
```

Weiterhin können Unions, genau wie Structs und Enums, über Methoden verfügen.

```zig
const IPAddr = union(IPType) {
    IPv4: [4]u8,
    IPv6: [8]u16,

    pub fn isIPv4(self: @This()) bool {
        return switch (self) {
            .IPv4 => true,
            else => false,
        };
    }
};
```
