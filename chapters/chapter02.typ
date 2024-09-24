#import "../tip-box.typ": tip-box, code
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

= Grundlagen

Zig ist eine kompilierte Sprache, d.h. sie wird, bevor der Programmcode ausgeführt werden kann, in eine Sprache übersetzt die vom Prozessor verstanden wird. Die Übersetzungsarbeit übernimmt dabei ein Compiler.

Zig verfügt über viel Datentypen, darunter vorzeichenbehaftete und -unbehaftete Ganzzahlen (Integer), Fließkommazahlen (Float), Booleans und Stirngs. Weiterhin besitzt Zig eine Vielzahl an Collection-Typen, darunter Arrays, Tuples.

Zig unterscheidet bei Variablen zwischen Variablen und Konstanten, welche Werte speichern, die über einen Namen referenziert werden. Der Name einer Variable beziehungsweise Konstante wird auch als Identifier bezeichnet. Konstanten sind nach ihrer Initialisierung nicht mehr veränderbar, während Variablen neu zugewiesen werden können. Durch die Unterscheidung zwischen Variablen und Konstanten kann die Absicht hinter einer Variablen-Deklaration eindeutiger ausgedrückt werden.

Zusätzlich zu simplen Typen stellt Zig zusätzliche Collection-Typen, darunter Hash-Maps und Array-Listen, über die Standardbibliothek bereit.

Weiterhin unterstützt Zig optionale Typen, welche die Abwesenheit eines Wertes ausdrücken. Das heißt ein optionaler Typ kann entweder einen Wert besitzen oder keinen. Optionals ersetzen unter anderem NULL-Pointer, wodurch vielen, aus C bekannten Speicherfehlern, vorgebeugt werden kann.

In Zig sind Fehler ebenfalls Werte, das heißt anstatt eine Exception zu werfen können Funktionen einen Fehler-Wert an die Aufrufende Funktion zurückgeben, welche potenzielle Fehler behandeln muss bevor auf den eigentlichen Rückgabewert zugegriffen werden kann.

== Kontanten und Variablen

Konstanten und Variablen bestehen aus einem Namen in Snake-Case (`buffer` oder `private_key`) und einem Typen (zum Beispiel `u8` oder `[]const u8`). Sie werden verwendet um Werte vom entsprechenden Typ zu binden (zum Beispiel `13` oder `"Hello, World!"`). Konstanten können nach ihrer Initialisierung nicht mehr neu zugewiesen werden.

=== Variablen-Deklarationen

Konstanten und Variablen müssen vor ihrer Verwendung deklariert und initialisiert werden. Konstanten werden mit dem `const` Schlüsselwort deklariert, während für Variablen `var` verwendet wird.

#code(
```zig
const es256 = "ES256";
var retries = 3;
retries -= 1;
```
)

In diesem Beispiel wird ein Konstante mit dem Namen `es256` deklariert und ihr wird der Wert `"ES256"` zugewiesen. Danach wird eine Variable mit dem Namen `retries` deklariert und der Wert `3` zugewiesen. Die Anzahl an Versuchen muss als Variable deklariert werden, da die Anzahl dekrementiert wird.

Sollte eine Variable sich nach ihrer Initialisierung nicht mehr verändern muss diese immer als Konstante deklariert werden! Dies wird vom Compiler sichergestellt.

Konstanten und Variablen müssen bei ihrer Deklarationen auch initialisiert werden. Alternativ kann ihnen auch der Wert `undefined` zugewiesen werden, was so viel bedeutet wie "der Wert der Variable ist zu diesem Zeitpunkt undefiniert".

#code(
```zig
var later: u8 = undefined;
later = 3;
```
)

Wichtig zu betonen ist bei der Verwendung von `undefined`, dass Zig den Typ der Variable nicht ableiten kann. Deshalb muss der Typ, bei der Deklaration der Variable, explizit mit angegeben werden.

=== Typ-Annotationen

Durch Typ-Annotation kann der Typ einer Konstante oder Variable angegeben werden. Hierzu wird hinter dem Variablen-Namen ein "`:`" angehängt, gefolgt vom Namen des Typen, der verwendet werden soll.

#code(
```zig
const hello: []const u8 = "Hello, World!";
```
)

Im obigen Beispiel wird eine Konstante mit dem Namen `hello` vom Typ `[]const u8` (String) deklariert.

In vielen Fällen kann Zig den Typ einer Variable ableiten, zum Beispiel durch den verwendeten Initialisierungswert. Es gibt jedoch auch Situationen, bei denen der Typ einer Variable klar ausgedrückt werden muss. Ein solcher Fall betrifft die Verwendung von `undefined`, bei dem der Compiler keinen Typen für die Variable ableiten kann. Es gibt jedoch auch Situationen, bei denen der Compiler den falschen Typen für eine Variable bestimmt.

#code(
```zig
var i = 0;
while (i < 10) : (i += 1) {}
```
)

Im obigen Beispiel wird der Variable `i` der Typ `comptime_int` zugewiesen, da Integer-Literale ebenfalls vom Typ `comptime_int` sind. Variablen vom Typ `comptime_int` müssen jedoch zur Kompilierzeit bekannt sein, was im gegebenen Fall nicht zutrifft, da `i` zur Laufzeit, innerhalb der Schleife, inkrementiert wird. 

Dies führt zu dem folgenden Fehler beim Kompilieren:

```bash
$ zig build-exe chapter02/integer.zig
error: variable of type 'comptime_int' must be const or comptime
    var i = 0;
        ^
note: to modify this variable at runtime, it must be given an explicit fixed-size number type
```

Um da Problem zu lösen muss der Variable `i` ein Integer-Typ mit einer bekannten Größe zugewiesen werden. Für Zähler-Variablen ist dies oft `usize`.

#code(
```zig
var i: usize = 0;
while (i < 10) : (i += 1) {}
```
)

=== Variablen benennen

Die Namen von Konstanten und Variablen müssen mit einem Buchstaben oder Underscore (`_`) beginnen, gefolgt einer beliebigen Anzahl an Buchstaben oder Ziffern. Dabei ist darauf zu achten, dass der Name nicht mit dem Identifier eines Schlüsselworts überlappt. Zum Beispiel ist es nicht erlaubt eine Konstante `const` zu nennen.

#code(
```zig
const pi = 3.14;
const private_key = "\x01\x02\x03\x04";
```
)

Es ist Konvention, die Namen von Variablen und Konstanten in Snake-Case zu schreiben, das heißt Wörter werden in Kleinbuchstaben geschrieben, getrennt durch einen Unterstrich (`_`).

Die Namen von Variablen dürfen niemals die Namen von Variablen aus einem umschließenden Scope überschatten, das heißt sie dürfen nicht den selben Namen besitzen.

Sollte ein Name nicht die genannten Bedingungen erfüllen, so kann die `@""` Syntax verwendet werden.

#code(
```zig
const @"π" = 3.14;
```
)

#tip-box([
    Die `@""` Syntax kann auch verwendet werden um Schlüsselwörter als Variablen-Namen verwenden zu können. Dies sollte jedoch vermieden werden um Verwirrung vorzubeugen.
])

=== Lokale Variablen

Lokale Variablen erscheinen innerhalb von Funktionen, Comptime-Blöcken und `@cImport`-Blöcken.

Einer lokalen Variable kann das `comptime` Schlüsselwort vorangestellt werden. Dadurch ist der Wert der Variable zur Kompilierzeit bekannt und das Laden und Speichern der Variable passiert während der semantischen Analyse des Programms, anstatt zur Laufzeit.

#code(
```zig
const std = @import("std");

test "comptime vars" {
    var x: i32 = 1;
    comptime var y: i32 = 1;

    x += 1;
    y += 1;

    try std.testing.expect(x == 2);
    try std.testing.expect(y == 2);
    
    // Da `y` zur Kompilierzeit bekannt ist und die Bedingung ebenfalls
    // zur Kompilierzeit überprüft werden kann, wird der gegebene
    // Block vom Compiler weg-optimiert, wodurch der Compile-Error
    // nicht ausgelöst wird.
    if (y != 2) {
        @compileError("wrong y value");
    }
}
```
)

Die Life-Time einer lokalen Variable, das heißt der Zeitraum in dem die Variable existiert, beginnt  und endet mit dem Block, indem sie deklariert wurde.

=== Container-Level Variablen

Container-Level Variablen werden außerhalb einer Funktion, Comptime-Blocks oder `@cImport`-Blocks deklariert und sind vergleichbar mit globalen Variablen in anderen Sprachen.

#tip-box([
    Jedes syntaktische Konstrukt in Zig, welches als Namensraum dient und Variablen- oder Funktionsdeklaraionen umschließt, wird als Container bezeichnet. Weiterhin können Container selbst Typdeklarationen sein, welche instantiiert werden können. Dazu zählen `struct`s, `enum`s, `union`s und sogar Quellcode-Dateien mit der Dateiendung _.zig_.
])

Der Initialisierungswert einer container-level Variable ist implizit `comptime`. Ist die deklarierte Variable eine Konstante, so ist ihr Wert zur Kompilierzeit bekannt, andernfalls ihr Wert zur Laufzeit bekannt.

#code(
```zig
const std = @import("std");

var x: i32 = sub(y, 10);
const y: i32 = sub(34, 9);

fn sub(a: i32, b: i32) i32 {
    return a - b;
}

test "Container-Level Variablen" {
    try std.testing.expect(x == 15);
    try std.testing.expect(y == 25);
}
```
)

Die Life-Time einer container-level Variable ist statisch, das heißt die Variable existiert während der gesamten Laufzeit des Programms. 

=== Statisch-lokale Variablen

Es ist möglich lokale Variablen mit einer statischen Life-Time zu deklarieren, indem ein Container innerhalb einer Funktion verwendet wird.

#code(
```zig
const std = @import("std");

fn next() i32 {
    const S = struct {
        var x: i32 = 0;
    };

    defer S.x += 1;
    return S.x;
}

test "Statische, lokale Variable" {
    try std.testing.expect(next() == 0);
    try std.testing.expect(next() == 1);
    try std.testing.expect(next() == 2);
}
```,
caption: [chapter02/static\_local\_variable.zig])

== Kommentare

Kommentare können genutzt werden um die Funktionsweise von Programmabschnitten zu Dokumentieren. Dabei unterscheidet Zig zwischen drei Arten von Kommentaren.

Normale Kommentare beginnen mit `//` und können an einer beliebigen Stelle im Code platziert werden. Alles was auf `//` innerhalb einer Zeile folgt ist Teil des Kommentars.

#code(
```zig
// Das ist ein Kommentar
```
)

Doc-Kommentare können für die Dokumentation einzelner Programmteile genutzt werden und beginnen mit `///`. Mehrere, hintereinander folgende Doc-Kommentare bilden einen zusammenhängenden Block und erlauben es Kommentare über mehrere Zeilen hinweg zu verfassen. Doc-Kommentare sind kontextabhängig und dokumentieren was auch immer dem Kommentar folgt.

#code(
```zig
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
```,
caption: [chapter02/docs.zig])

Top-Level-Kommentare beginnen mit `//!` und dokumentieren den umschließenden Container. Sie werden in der Regel genutzt um Module zu dokumentieren.

#tip-box([
    Mit *`zig test -femit-docs <your-code>.zig`* können die Doc- und Top-Level-Kommentare in eine HTML-Seite umgewandelt werden. Zig wird hierfür einen neuen Ordner mit dem Namen _docs_ anlegen. Mit *`python3 -m http.server`* kann ein HTTP-Server gestartet werden um die Dokumentation anzuzeigen.

    *Zurzeit scheint es jedoch noch Probleme mit dem Erzeugen zu geben.*
])

== Ganzzahlen (Integer)

Integer sind Ganzzahlen, das heißt sie Besitzt keine Bruchkomponente und können entweder vorzeichenbehaftet (_signed_) oder vorzeichenunbehaftet (_unsigned_) sein.

Zig unterstützt Ganzzahlen mit einer beliebigen Bitbreite. Der Bezeichner eines jeden Integer-Typen beginnt mit einem Buchstaben `i` (signed) oder `u` (unsigned) gefolgt von einer oder mehreren Ziffern, welche die Bitbreite in Dezimal darstellen. Als Beispiel, `i7` ist eine vorzeichenbehaftete Ganzzahl der sieben Bit zur Kodierung der Zahl zur Verfügung stehen. Die Aussage, dass die Bitbreite beliebig ist entspricht dabei nicht ganz der Wahrheit. Die maximal erlaubte Bitbreite beträgt $2^16 - 1 = 65535$. Beispiele für Integer sind:

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Typ*], [*Wertebereich*],
  ),
  [`i7`],
  [$-2^6$ bis $2^6 - 1$],

  [`i32`],
  [$-2^31$ bis $2^31 - 1$],

  [`u8`],
  [$0$ bis $2^8 - 1$],

  [`u64`],
  [$0$ bis $2^64 - 1$],
)

=== Darstellung von Integern im Speicher

Vorzeichenbehaftete Ganzzahlen werden im Zweierkomplement dargestellt #footnote[https://en.wikipedia.org/wiki/Two's_complement]. In Assembler wird nicht zwischen vorzeichenbehafteten und vorzeichenunbehafteten Zahlen unterschieden. Alle mathematischen Operationen werden von der CPU auf Registern, mit einer festen Bitbreite (meist 64 Bit auf modernen Computern), ausgeführt. Dabei entspricht jede, vom Computer ausgeführte, arithmetische Operationen effektiv einem "Rechnen mit Rest", auch bekannt als modulare Arithmetik #footnote[https://de.wikipedia.org/wiki/Modulare_Arithmetik]. Die Bitbreite $m$ der Register (z.B. 64) repräsentiert dabei den Modulo $2^m$. Damit entspricht ein 64 Bit Register dem Restklassenring $ZZ_(2^64) = {0, 1, 2, ..., 2^64 - 1}$ und jegliche Addition zweier Register resultiert in einem Wert der ebenfalls in $ZZ_(2^64)$ liegt, d.h. auf _x86\_64_ wäre die Instruktion `add rax, rbx` äquivalent zu $"rax" = "rax" + "rbx" "mod" 2^64$. Diese Verhalten überträgt sich analog auf Ganzzahlen in Zig.

Das Zweierkomplement einer Zahl $a in ZZ_m$ ist das additive Inverse $a'$ dieser Zahl, d.h. $a + a' equiv 0$. Dieses kann mit $a' = m - a$ berechnet werden. Für `i8` wäre das additive Inverse zu $a = 4$ die Zahl $a' = 2^8 - 4 = 256 - 4 = 252$. Addiert man beide Zahlen modulo $256$, so erhält man wiederum das neutrale Element $0$, $a + a' mod 256 = 4 + 252 mod 256 = 256 mod 256 = 0$. Das Zweierkomplement hat seinen Namen jedoch nicht von der Subtraktion, sondern von der speziellen Weise wie das additive Inverse einer Zahl bestimmt wird. Dieser Vorgang kann wie folgt beschrieben werden:

1. Gegeben eine Zahl in Binärdarstellung, invertiere jedes Bit, d.h. jede $1$ wird zu einer $0$ und umgekehrt.
2. Addiere $1$ auf das Resultat und ignoriere mögliche Überläufe.

Für das obige Beispiel mit der Zahl $4$ vom Typ `i8` sieht dies wie folgt aus:
$
00000100_2 &= 4_16 && "invertiere alle Bits der Zahl 4" \
11111011_2 &= 251_16 && "addiere 1 auf die Zahl 251" \
11111100_2 &= 252_16
$

=== Integer-Literale

Zur Compile-Zeit bekannte Literale vom Typ `comptime_int` haben kein Limit was ihre Größe (in Bezug auf die Bitbreite) und konvertieren zu anderen Integertypen, solange das Literal im Wertebereich des Typen liegt.

#code(
```zig
// Variable `i` vom Typ `comptime_int`
var i = 0;
```
)

Optional können die Prefixe `0x`, `0o` und `0b` an ein Literal angehängt werden um Literale in Hexadezimal, Octal oder Binär anzugeben, z.B. `0xcafebabe`.

Um größere Zahlen besser lesbar zu machen, kann ein Literal mit Hilfe von Unterstrichen aufgeteilt werden, z.B. `0xcafe_babe`.

=== Laufzeit-Variablen

Um die Variable zur Laufzeit modifizieren zu können, muss ihr eine expliziter Type mit fester Bitbreite zugewiesen werden. Dies kann auf zwei weisen erfolgen.

1. Deklaration der Variable `i` mit explizitem Typ, z.B. `var i: usize = 0`.
2. Verwendung der Funktion `@as()`, von welcher der Compiler den Type der Variable `i` ableiten kann, z.B. `var i = @as(usize, 0)`.

Ein häufiger Fehler, der aber schnell behoben ist, ist die Verwendung einer Variable vom Typ `comptime_int` in einer Schleife.

#code(
```zig
var i = 0;
while (i < 100) : (i += 1) {}
```
)

Was zu einem entsprechenden Fehler zur Kompilierzeit führt.

```bash
$ zig build-exe chapter02/integer.zig
error: variable of type 'comptime_int' must be const or comptime
    var i = 0;
        ^
note: to modify this variable at runtime, it must be given an explicit fixed-size number type
```

Der Zig-Compiler ist dabei hilfreich, indem er neben dem Fehler auch einen Lösungsansatz bietet. Nachdem der Variable `i` ein expliziter Typ zugewiesen wird (`var i: usize`) compiliert das Programm ohne weitere Fehler.

=== Integer-Operatoren

Zig unterstützt verschiedene Operator für das Rechnen mit Integern, darunter `+` (Addition), `-` (Subtraktion), `*` (Multiplikation) und `/` (Division).

Die Verwendung dieser Operatoren führt bei einem Überlauf jedoch zu undefiniertem Verhalten (engl. undefined behavior). Aus diesem Grund stellt Zig spezielle Versionen dieser Operatoren zur Verfügung, darunter:

- Operatoren für Sättigungsarithmetik: Alle Operationen laufen in einem festen Intervall zwischen einem Minimum und einem Maximum ab welches nicht unter- bzw. überschritten werden kann.
    - Addition (`+|`): `@as(u8, 255) +| 1 == @as(u8, 255)`
    - Subtraktion (`-|`): `@as(u32, 0) -| 1 == 0`
    - Multiplikation (`*|`): `@as(u8, 200) *| 2 == 255`
- Wrapping-Arithmetik: Dies ist äquivalent zu modularer Arithmetik.
    - Addition (`+%`): `@as(u32, 0xffffffff) +% 1 == 0`
    - Subtraktion (`-%`): `@as(u8, 0) -% 1 == 255`
    - Multiplikation (`*%`): `@as(u8, 200) *% 2 == 144`

=== Integer-Bounds

Auf den Minimal- und Maximalwert eines Integers kann mit `std.math.minInt` und `std.math.maxInt` zugegriffen werden.

#code(
```zig
try testing.expect(minInt(i128) == -170141183460469231731687303715884105728);
try testing.expect(maxInt(i128) == 170141183460469231731687303715884105727);
```
)

Beide Funktionen erwarten als Argument den Integer-Typ, für den das Minimum oder Maximum bestimmt werden soll. Da beide Funktionen `comptime` sind wird der Rückgabewert zur Kompilierzeit bestimmt.

== Fließkommazahlen (Float)

Fließkommazahlen haben eine Bruchkomponente, wie etwa `3.14` oder `-0.5`.

Im Gegensatz zu Integern erlaubt Zig keine beliebige Bitbreite für Fließkommazahlen. Zur Verfügung stehen:

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Typ*], [*Repräsentation*],
  ),
  [`f16`],
  [IEEE-754-2008 binary16],

  [`f32`],
  [IEEE-754-2008 binary32],

  [`f64`],
  [IEEE-754-2008 binary64],

  [`f80`],
  [IEEE-754-2008 80-bit extended precision],

  [`f128`],
  [IEEE-754-2008 binary128],
)

Der Typ `f32` entspricht dem Typ `float` (single precision) in C, während `f64` dem Typ `double` (double precision) entspricht. Je nach Prozessortyp stehen dedizierte Maschineninstruktionen für zumindest einen Teil der Typen zur Verfügung, was eine effizientere Verwendung ermöglicht. Auf _x86\_64_ Prozessor stehen z.B. Instruktionen für single und double Precision zur Verfügung.

=== Float-Literale

Literale sind immer vom Typ `comptime_float`, welcher äquivalent zum größtmöglichen Fließkommatypen (`f128`) ist, und können zu jedem beliebigen Fließkommatypen konvertiert werden. Enthält ein Literal keinen Bruchteil, so ist eine Konvertierung zu einem Integertyp ebenfalls möglich.

Alle Float-Literale haben einen Dezimalpunkt (`.`). Sie können entweder als Dezimalzahl angegeben werden (ohne Präfix) oder als Hexadezimalzahl (mit dem Präfix `0x`). Optional kann ein Exponent mit angegeben werden. Für Dezimalzahlen wird hierfür ein `E` oder `e` verwendet und für Hexadezimalzahlen ein `P` oder `p`.

Für Dezimalzahlen mit einem Exponenten `e` wird die angegebene Fließkommazahl mit $10^e$ multipliziert:

- `123.0E+77` = $123.0 * 10^77$

Für Hexadezimalzahlen mit einem Exponenten `p` wird die Fließkommazahl mit $2^p$ multipliziert:

- `0x103.70p-5` = $103.70_16 * 2^(-5)$

#code(
```zig
const fp = 123.0E+77;
const hfp = 0x103.70p-5;
```
)

=== Darstellung von Floats im Speicher

Die interne Darstellung einer Fließkommazahl besteht für das Format _IEEE-754_ aus einem Vorzeichenbit, gefolgt von einem Exponenten und einem Bruch. Wie viele Bits jeweils für Exponent und Bruch zur Verfügung stehen ist abhängig von der Bitbreite der Fließkommazahl. Für _IEEE-754 binary32_ sieht dies wie folgt aus:

#table(
    columns: 7,
    table.header(
        [31], [30], [...], [23], [22], [...], [0]
    ),
    [*s*],
        table.cell(colspan: 3, [exponent (e)]),
        table.cell(colspan: 3, [fraction (f)]),
)

Diese Darstellung entspricht der Gleichung $(-1)^s * 1.f * 2^(e - 127)$. Der Bruch $f$ entspricht einer normalisierten, binär kodierten Fließkommazahl, d.h. die Zahl wird um eine entsprechende Anzahl an Stelle verschoben, sodass genau eine führende Eins vor dem Komma steht. Als Beispiel entspricht die Fließkommazahl $3.25$ in binär der Zahl $11.01$ oder anders ausgedrückt $11.01 * 2^0$. Um die Zahl zu normalisieren wird diese nun um eine Stelle nach rechts verschoben $1.101 * 2^1$. Die Zahl nach der führenden Eins ($101$) entspricht $f$ und der Exponent $e$ ist die Summe des Exponenten der normalisierten Darstellung und einem Bias (im Fall von `f32` ist dieser $127$), d.h. $e = 1 + 127 = 128_16 = 10000000_2$. Damit wird $3.25$ wie folgt kodiert:

#table(
    columns: 7,
    table.header(
        [31], [30], [...], [23], [22], [...], [0]
    ),
    [0],
        table.cell(colspan: 3, [$10000000_2$]),
        table.cell(colspan: 3, [$10100000000000000000000_2$]),
)

#tip-box([
    Aufgrund der Darstellung von Fließkommazahlen kann sich die Ausführung bestimmter Operationen, wie ein Tests auf Gleichheit (`==`), als trickreich herausstellen. Ein Beispiel ist die wiederholte Addition der Fließkommazahl $0.1$. Die Summe $sum_(k=1)^10 0.1$ ist erwartungsgemäß $1.0$, je nach Präzision der Fließkommazahl gilt jedoch $sum_(k=1)^10 0.1 eq.not 1.0$. 
])

== Konvertierung von numerischen Typen

Von Zeit zu Zeit kann es nötig sein einen numerischen Typen in einen anderen zu konvertieren. Hierfür stehen die eingebauten Funktionen `@intCast()` und `@floatCast()` zur Verfügung.

=== Integer Konvertierung

Die Funktion `@intCast(anytype)` konvertiert einen Integer zu einem anderen Integer, wobei der numerische Wert beibehalten wird. Der Typ des Rückgabewertes wird dabei vom Compiler abgeleitet. Hierzu muss `@as()` in Kombination mit `@intCast()` verwendet werden. Alternativ kann einer Variable auch explizit ein Typ zugewiesen werden, an den der konvertierte Wert gebunden werden soll.

#code(
```zig
test "Konvertierungs-Test: pass" {
    var a: u16 = 0x00ff; // runtime-known
    _ = &a;
    const b: u8 = @intCast(a);
    _ = b;
    const c = @as(u8, @intCast(a));
    _ = c;
}
```,
caption: [chapter02/conversion.zig])

Grundsätzlich kann zwischen einer Narrowing- und Widening-Konvertierung unterschieden werden. Bei ersterer ist der Ziel-Typ kleiner als der ursprüngliche Typ. Hierdurch kann es passieren das der numerische Wert "out-of-range" ist, das heißt der Ziel-Typ hat nicht genug Bits um den Wert im Speicher darzustellen. Ein solcher Fall führt zu undefiniertem Verhalten, wobei Zig, je nach Optimierung, das "Abschneiden" von Bits erkennt und den Prozess vorzeitig beendet.

#code(
```zig
test "Konvertierungs-Test: fail" {
    var a: u16 = 0x00ff; // runtime-known
    _ = &a;
    const b: u7 = @intCast(a);
    _ = b;
}
```,
caption: [chapter02/conversion.zig])

```bash
$ zig test conversion.zig 
thread 363318 panic: integer cast truncated bits
zig-book/code/chapter02/conversion.zig:13:19: 0x103cdad in test.Konvertierungs-Test: fail (test)
    const b: u7 = @intCast(a);
                  ^
zig-linux-x86_64-0.13.0/lib/compiler/test_runner.zig:157:25: 0x1048099 in mainTerminal (test)
        if (test_fn.func()) |_| {
                        ^
zig-linux-x86_64-0.13.0/lib/compiler/test_runner.zig:37:28: 0x103e11b in main (test)
        return mainTerminal();
                           ^
zig-linux-x86_64-0.13.0/lib/std/start.zig:514:22: 0x103d259 in posixCallMainAndExit (test)
            root.main();
                     ^
zig-linux-x86_64-0.13.0/lib/std/start.zig:266:5: 0x103cdc1 in _start (test)
    asm volatile (switch (native_arch) {
    ^
???:?:?: 0x0 in ??? (???)
```

Sollte es erlaubt sein einen Wert, bei einer Narrowing-Konvertierung, abzuschneiden, so kann entweder `@truncate` oder alternativ der Und-Operator (`&`) in Kombination mit einer Bit-Maske verwendet werden.

Widening-Konvertierungen wiederum sind unkritisch und damit immer erfolgreich.

=== Float Konvertierung

Die Funktion `@floatCast(anytype)` konvertiert einen Float zu einem anderen Float, wobei der numerische Wert an Präzision verlieren kann. Die Konvertierung von Floats ist dabei sicher. Der Typ des Rückgabewerts wird wie bei der Konvertierung von Integern abgeleitet.

#code(
```zig
test "Float Konvertierung" {
    var a: f32 = 1234567.0; // runtime-known
    _ = &a;
    const b: f16 = @floatCast(a);
    _ = b;
}
```,
caption: [chapter02/conversion.zig])

== Typen Alias

Alle primitiven Typen in Zig haben `type` als ihren Meta-Typ und können selbst an Konstanten gebunden werden. Damit erlaubt Zig die Definition eines Alias für einen bestehenden Typen.

Ein Alias ist nützlich, um einen Typen bei einem Namen zu referenzieren. Beispielsweise werden Universally Unique Identifier (UUID) #footnote[https://en.wikipedia.org/wiki/Universally_unique_identifier] als 128-Bit-Zahl kodiert.

#code(
```zig
/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const Uuid = u128;
```,
caption: [https://github.com/r4gus/uuid-zig/blob/master/src/core.zig])

Nachdem ein Alias definiert wurde kann dieser überall verwendet werden, wo auch der ursprüngliche Bezeichner des Typen verwendet werden kann.

#code(
```zig
/// Create a version 4 UUID using a user provided RNG
pub fn new2(r: std.rand.Random) Uuid {
    // Set all bits to pseudo-randomly chosen values.
    var uuid: Uuid = r.int(Uuid);
    // Set the two most significant bits of the
    // clock_seq_hi_and_reserved to zero and one.
    // Set the four most significant bits of the
    // time_hi_and_version field to the 4-bit version number.
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800040000000000000;
    return uuid;
}
```,
caption: [https://github.com/r4gus/uuid-zig/blob/master/src/v4.zig])

== Booleans

Zig besitzt einen primitiven Boolean Typ `bool`. Ein Boolean ist ein Daten-Typ der zwei mögliche Werte annehmen kann `true` oder `false`. Er ist nach Georg Boole #footnote[https://en.wikipedia.org/wiki/George_Boole] benannt, der die Boolsche-Algebra definierte.

Booleans werden primär in Conditional-Satements und -Expressions (Kontrollstrukturen) verwendet #footnote[https://en.wikipedia.org/wiki/Conditional_(computer_programming)], zum Beispiel in Kombination mit If-Then-Else Blöcken, um zu bestimmen, welcher Block ausgeführt werden soll.

#code(
```zig
const name = "Sesam, öffne dich!";

if (std.mem.eql(u8, name, "Sesam, öffne dich!") {
    std.log.info("Ruhm und Reichtum!", .{});
} else {
    std.log.info("...", .{});
}
```
)

Die Funktion `std.mem.eql` überprüft ob die zwei gegebenen Strings, bezogen auf ihren Inhalt, gleich sind. Falls ja wird der Wert `true` zurückgegeben, andernfalls der Wert `false`.

Im Gegensatz zu C verhindert Zig, dass numerische Werte als Booleans verwendet werden #footnote[In C ist der Wert `0` äquivalent zu `False` und alle verbleibenden Werte äquivalent zu `True`.].

== defer

Mit dem `defer` Schlüsselwort können Ausdrücke und Blöcke markiert werden, die beim Verlassen eines Blocks ausgeführt werden sollen. Solche `defer`-Ausdrücke und -Blöcke werden in der umgekehrten Reihenfolge ausgeführt, in welcher sie definiert wurden.

#code(
```zig
const std = @import("std");
const print = std.debug.print;

fn myDefer() void {
    defer {
        print("Wird als zweites ausgeführt\n", .{});
    }

    defer print("Wird als erstes ausgeführt\n", .{});

    if (false) {
        defer print("Wird nie ausgeführt\n", .{});
    }
}

test "defer test #1" {
    myDefer();
}
```,
caption: [chapter02/defer.zig])

`defer`s werden dabei nur ausgeführt, wenn Sie beim Ausführen eines Blocks auch erreicht wurden. Im obigen Beispiel kommt zuerst ein `defer`-Block vor, gefolgt von einem `defer`-Ausdruck. Da `defer`s in umgekehrter Reihenfolge ausgeführt werden, wird beim Verlassen der Funktion zuerst "_Wird als erstes ausgeführt_" auf der Kommandozeile ausgegeben, gefolgt von "_Wird als zweites ausgeführt_". "_Wird nie ausgeführt_" wird nicht ausgegeben, da die If-Bedingung immer `false` ist und somit der If-Block nie ausgeführt wird.

`defer`s eignen sich besonders gut zum aufräumen von Ressourcen. Ein Beispiel hierfür ist die Deallokation von dynamisch alloziertem Speicher. Es ist gängige Praxis, dass auf die dynamische Allokation von Speicher ein `defer` folgt, welches den Speicher wieder frei gibt, sollte dieser nach dem Verlassen des umschließenden Blocks nicht mehr benötigt werden.

#code(
```zig
var mem = try std.heap.c_allocator.alloc(T: u8, n: 16);
defer std.heap.c_allocator.free(mem);
// do something...
```
)

== Optionals

In Situationen bei denen eine Wert fehlen kann, können Optionals verwendet werden. Ein Optional repräsentiert zwei mögliche Zustände: Entweder es ist ein Wert vorhanden oder es ist kein Wert vorhanden. Dies ist nicht zu verwechseln mit undefinierten Werten, die bei der Verwendung von `undefined` vorkommen!

Als ein Beispiel stellt die Zig Standardbibliothek die Funktion `std.math.cast` zur Verfügung. Diese erlaubt das Konvertieren eines Integer in einen anderen Integer-Typen. Falls der gegebene Wert nicht in den neuen Integer-Typen passt, so wird von der Funktion `null` zurückgegeben.

#code(
```zig
const std = @import("std");
const cast = std.math.cast;

test "Integer Konvertierung" {
    try std.testing.expect(cast(u8, @as(u32, 300)) == null);
    try std.testing.expect(cast(u8, @as(u32, 255)).? == @as(u8, 255));
}
```
)

Ein optionaler Typ besteht aus einem beliebigen Typen, dem ein `?` vorangestellt wird, zum Beispiel `?u32` oder `?[]const u8`.

=== null

Um einer optionalen Variable einen wertlosen Zustand zuzuweisen, wird der Wert `null` verwendet.

#code(
```zig
var optional: ?u32 = 7;
optional = null;
```
)

Sollte eine optionale Variable einen Wert besitzen, so wird dieser als "ungleich zu `null`" betrachtet. Dies kann mit dem Gleicheits- (`==`) beziehungsweise Ungelichheits-Operator (`!=`) abgefragt werden.

#code(
```zig
test "Optional" {
    const num: ?u8 = std.math.cast(u8, @as(u32, 255));

    if (num != null) {
        try std.testing.expect(num.? == 255);
    } else {
        try std.testing.expect(1 == 0); // fail
    }
}
```,
caption: [chatper02/optionals.zig])

Mit dem `?`-Operator kann auf den Wert eines Optionals zugegriffen werden. Es sollte jedoch sichergestellt werden, dass ein Wert existiert!

Das obige Beispiel kann auch wie folgt geschrieben werden:

#code(
```zig
test "Optional #2" {
    const num: ?u8 = std.math.cast(u8, @as(u32, 255));

    if (num) |n| {
        try std.testing.expect(n == 255);
    } else {
        try std.testing.expect(1 == 0); // fail
    }
}
```,
caption: [chatper02/optionals.zig])

Optionale Variablen können als Bedingung, innerhalb einse If-Statements, verwendet werden. Sollte `num` einen Wert besitzen, so wird dieser an `n` gebunden und der If-Block wird betreten. Andernfalls wird der Else-Block ausgeführt.

Variablen die nicht als "optional" deklariert wurden enthalten garantiert immer einen Wert! Dies vereinfacht es, Fälle bei denen ein Wert fehlen kann, wie etwa der Zeiger bei einer verketteten Liste, zu handhaben. Optionals erzwingen es, explizit auf den Wert einer optionalen Variable zuzugreifen. Entweder durch Verwendung des `?`-Operators oder eines If-Statements. Damit wird verhindert, dass ein optionaler Wert aus Versehen als nicht optionaler Wert gehandhabt wird.

Je nach Situation kann wie folgt mit fehlenden Werten umgegangen werden:

- Überspringe den Code der auf den eigentlichen Wert angewandt werden würde.
- Bereitstellen eines Fallback-Werts.
- Propagiere den `null` Wert an die darüber liegende Funktion oder beende den Prozess vorzeitig.

#code(
```zig
test "Handling" {
    var num: ?u8 = std.math.cast(u8, 250);

    // Überspringe Block falls `num == null`
    if (num) |*n| {
        n.* += 1;
    }
    try std.testing.expect(num.? == 251);

    // Stelle einen Fallback-Wert bereit
    const num2: u8 = if (std.math.cast(u8, 256)) |n| n else 255;
    try std.testing.expect(num2 == 255);
}
```,
caption: [chatper02/optionals.zig])

Neben If-Statements können Optionals auch in While-Schleifen verwendet werden. Sollte das verwendete Optional `null` sein so wird aus der Schleife ausgebrochen, andernfalls wird eine Iteration der schleife Durchlaufen.

#code(
```zig
test "while" {
    const S = struct {
        pub fn next() ?u2 {
            const T = struct {
                var v: ?u2 = 0;
            };

            defer {
                if (T.v) |*v| {
                    if (v.* == 3) T.v = null else v.* += 1;
                }
            }

            return T.v;
        }
    };

    const stdout = std.io.getStdOut();

    while (S.next()) |value| {
        try stdout.writer().print("{d}\n", .{value});
    }
}
```,
caption: [chatper02/optionals.zig])

In diesem Beispiel wird eine Funktion `next()` definiert, die eine statische, lokale Variable `v` besitzt. Diese wird mit `0` initialisiert. Bei jedem Aufruf von `next()` wird der aktuelle Wert von `v` zurückgegeben. Der `defer` Block wird vor der Rückkehr aus der Funktion ausgeführt und inkrementiert `v`, jedoch nur falls `v` nicht gleich drei ist. Sollte `v` gleich drei sein, so wird `v` der `null`-Wert zugewiesen.

Verwendet man den Rückgabewert von `next()` als Bedingung einer While-Schleife so wird der Rückgabewert an `value` gebunden, solange dieser nicht gleich `null` ist, das heißt `value`hat den Typ `u2`.

Führt man den Test aus, so sieht man, dass die Zahlen 0 bis 3 auf der Kommandozeile ausgegeben werden, bevor aus der Schleife ausgebrochen wird.

```bash
$ zig test optionals.zig 
0
1
2
3
All 4 tests passed.
```

== Arrays und Slices

Zig besitzt eine Vielzahl an Datentypen um eine (lineare) Sequenz an Werten im Speicher darzustellen, darunter:

- Der Typ `[N]T` repräsentiert ein Array vom Typ `T` bestehend aus `N` Werten. Die Größe eines Arrays ist zur Compilezeit bekannt und Arrays werden grundsätzlich auf dem Stack alloziert. Damit kann ein Array weder erweitert noch verkleinert werden.
- Der Typ `[]T` bzw. `[]const T` repräsentiert ein Slice vom Typ `T`, bestehend aus einem Zeiger und einer Länge. Die Länge eines Slices ist zur Laufzeit bekannt. Slices referenzieren eine Sequenz von Werten. Dies kann z.B. ein Array sein oder auch eine auf dem Heap gespeicherte Sequenz. Die von einem konstanten Slice `[]const T` referenzierten Werte können gelesen, jedoch nicht verändert werden, während die Werte eines Slices `[]T` sowohl gelesen als auch verändert werden können.

Sowohl Arrays als auch Slices erlauben den Zugriff auf deren Länge durch den Ausdruck `.len`.

#code(
```zig
var a = [_]u8{ 1, 2, 3, 4 };
std.log.info("length of a is {d}", .{a.len});
const s = &a;
std.log.info("length of a is still {d}", .{s.len});
```,
caption: [chapter02/slices.zig])

Mit dem Address-Of Operator `&` kann ein Slice für ein Array erzeugt werden. Alternativ kann auch der Ausdruck `a[0..]` verwendet werden, der einen Bereich innerhalb des Arrays beschreibt. Grundsätzlich liegt das erste Element einer Sequenz immer an Index $0$ und es kann mit `a[0]` auf dieses zugegriffen werden. Das letzte Element liegt immer an der Stelle `a.len - 1` und es kann mit `a[a.len - 1]` darauf zugegriffen werden. Der Index muss dabei immer ein Integer vom Typ `usize` oder ein Literal sein, das zu diesem Typ konvertiert werden kann. Die Verwendung anderer Typen als Index führt zu einem Fehler zur Compilezeit.

Auf den Zeiger eines Slices kann mit `.ptr` zugegriffen werden, z.B. `s.ptr`.

Zig überprüft bei dem Zugriff auf eine Array oder Slice zur Laufzeit, dass der Index innerhalb des Speicherbereichs der Sequenz liegt. Ließt eine Anwendung über die Grenzen der Sequenz, so führt dies zu einem Fehler zur Laufzeit der den Prozess beendet. Dies verhindert typische Speicherfehler wie Buffer-Overflows and Buffer-Overreads die in Sprachen wie C weit verbreitet sind und in der Vergangenheit zu Hauf von Angreifern ausgenutzt wurden um Anwendungen zu exploiten.

#code(
```zig 
var i: usize = 0;
while (true) : (i += 1) {
    a[i] += 1;
}
```,
caption: [chapter02/slices.zig])

```bash
$ zig build-exe slices.zig -Doptimize=ReleaseFast
$ ./slices 
info: length of a is 4
info: length of a is still 4
thread 1232 panic: index out of bounds: index 4, len 4
slices.zig:14:10: 0x103544c in main (slices)
        a[i] += 1;
         ^
start.zig:514:22: 0x1034c99 in posixCallMainAndExit (slices)
            root.main();
                     ^
start.zig:266:5: 0x1034801 in _start (slices)
    asm volatile (switch (native_arch) {
    ^
???:?:?: 0x0 in ??? (???)
Aborted (core dumped)
```

=== Arrays

Es gibt eine Vielzahl von Möglichkeiten um Arrays in Zig zu definieren. Die einfachste Möglichkeit ist, eine Sequenz von Werten in geschweiften Klammern anzugeben.

#code(
```zig
const prime: [5]u8 = .{2, 3, 5, 7, 11}; 
const names = [3][]const u8{"David", "Franziska", "Sarah"};
```
)

Für den Fall, dass initial keine Werte bekannt sind kann ein Array mit `undefined` initialisiert werden. In diesem Fall ist der Inhalt des Speichers undefiniert.

#code(
```zig
const some: [1000]u8 = undefined;
```
)

Arrays können aber auch mit einem bestimmten Wert initialisiert werden. Im unteren Beispiel wird das gesamte Array mit `0` Werten initialisiert.

#code(
```
const some: [1000]u8 = .{0} ** 1000;
```
)

Die Länge eines Arrays muss immer zur Compilezeit bekannt sein. Dementsprechend können keine Variablen zur Angabe der Länge verwendet werden, außer die Variable ist vom Typ `comptime_int`. Sollte ein Array benötigt werden, dessen Länge nur zur Laufzeit bekannt ist, so muss der Speicher entweder manuell alloziert oder auf einen Kontainertypen wie `ArrayList` aus der Standardbibliothek zurückgegriffen werden #footnote[Mehr dazu in folgenden Kapiteln.].

Viel Funktionen die über Sequenzen arbeiten erwarten ein Slice und kein Array. Zig konvertiert dabei nicht automatisch Arrays zu Slices, d.h. bei einem Aufruf muss explizit der Address-Of Operator `&` auf das Array angewandt werden oder alternativ ein Slice mit dem `[]` Operator festgelegt werden.

#code(
```zig 
const std = @import("std");

pub fn main() void {
    const a: [5]u8 = .{ 1, 2, 3, 4, 5 };

    foo(&a);
    foo(a[1..]);
}

fn foo(s: []const u8) void {
    for (s) |e| {
        std.log.info("{d}", .{e});
    }
}
```,
caption: [chapter02/coersion.zig])

```bash
$ ./coersion 
info: 1
info: 2
info: 3
info: 4
info: 5
info: 2
info: 3
info: 4
info: 5
```

=== Slices

Slices `[]T` werden ohne Angabe einer Länge geschrieben und repräsentieren eine lineare Sequenz an Werten. Konzeptionell ist ein Slice eine Zeiger vom Typ `std.builtin.Type.Pointer`. Schaut man sich die Definition von `Slice` in _zig/src/mutable\_value.zig_ #footnote[https://github.com/ziglang/zig/blob/624fa8523a2c4158ddc9fce231181a9e8583a633/src/mutable_value.zig] an, so sieht man, dass ein Slice durch einen Zeiger (`ptr`) auf den Beginn des referenzierten Speicherbereichs und eine Länge (`len`) beschrieben wird.

#code(
```zig 
pub const Slice = struct {
    ty: InternPool.Index, // wir ignorieren dieses Feld :)
    /// Must have the appropriate many-ptr type.
    ptr: *MutableValue,
    /// Must be of type `usize`.
    len: *MutableValue,
};
```,
caption: [github.com/ziglang/zig/src/mutable_value.zig])

Je nach Typ einer Variable bzw. eines Parameters konvertiert Zig die Referenz zu einem Struct automatisch in ein Slice.

#code(
```zig
const b: [3][]const u8 = .{ "David", "Franziska", "Sarah" };

// Zig konvertiert die Referenz automatisch zu einem Slice.
const sb: []const []const u8 = &b;
_ = sb;

// `rb` ist ein Pointer zu einem Array.
const rb: *const [3][]const u8 = &b;
_ = rb;
```
)

Da `b` eine Konstante ist, muss auch das Slice `sb` (`[]const T`), sowie der Pointer `rb` auf das Array (`*const [N]T`) konstant sein. Wäre `b` eine Variable, so wäre auch das `const`, in Bezug auf das Slice bzw. den Pointer, optional, je nachdem ob das Array durch die jeweilige Referenz verändert werden soll oder nicht.

```
               /----------------------\
            b |                        |
       -------v------------------------|----------------------
stack |    | | | |                    | |3|                   |
       -----|-|-|---------------------------------------------
            |  \ \----------------      sb
             \  |                 |
              | -------|          |
       -------v--------v----------v---------------------------
data  |    |"David"|"Franziska"|"Sarah"|                      |
       -------------------------------------------------------
```

Mithilfe des `[]` Operators können Slices für einen bestehenden Speicherbereich angegeben werden. Innerhalb der eckigen Klammern muss dafür ein Bereich spezifiziert werden, der durch das Slice eingegrenzt werden soll:

- `[0..]` : Der gesamte Bereich, vom ersten bis zum letzten Element.
- `[N..M]` : Ein Bereich beginnend ab Index `N` (eingeschlossen) und endend bei Index `M` (ausgeschlossen).

#code(
```zig
const name = "David";
// Die ersten drei Buchstaben
std.log.info("{s}", .{name[0..3]});
// Die letzten zwei Buchstaben
std.log.info("{s}", .{name[3..]});
// Die mittleren drei Buchstaben
std.log.info("{s}", .{name[1..4]});
```
)

Um Buffer-Overreads vorzubeugen überprüft Zig, dass die angegeben Indices valide sind. Sind die Indices zur Compilezeit bekannt, so führt ein invalider Index zu einem Compile-Fehler, andernfalls zu einer Panic zur Laufzeit.

#code(
```zig 
const a = "this won't work";
// ...
const n: usize = 20;
std.log.info("{s}", .{a[1..n]});
```,
caption: [chapter02/slice_error.zig])

Versucht man den obigen Code mit *`zig build-exe chapter02/slice_error.zig`* zu Compilieren so erhält man den folgenden Fehler:

```bash
error: end index 20 out of bounds for array of length 15 +1 (sentinel)
    std.log.info("{s}", .{a[1..n]});
```

== Enums

== Errors

Während der Ausführung von Zig-Code kann ein Programm auf Fehler zur Laufzeit stoßen. Dabei kann es sich zum Beispiel um eine fehlende Datei handeln, die nicht geöffnet werde kann.

Im Gegensatz zu Optionals, welche die Abwesenheit eines Wertes kommunizieren können, geben Fehler mehr Aufschluss über den Grund, warum der Aufruf einer Funktion fehlgeschlagen ist. Außerdem unterstützt Zig das Propagieren von Fehlern.

Zig betrachtet Errors als Werte, die in einem Error-Set zusammengefasst werden. Ein Error-Set ist vergleichbar zu einem Enum, wobei jedem Error-Bezeichner ein eindeutiger ganzzahliger Wert größer 0 zugewiesen wird #footnote[Standardmäßig ist der einem Error zugrunde liegende Integer-Typ ein `u16`.]. Wird ein Error-Bezeichner (zum Beispiel `error.OutOfMemory`) mehrfach definiert, so wird diesem immer der selbe numerische Wert zugewiesen.

Error-Sets können mit dem `error` Schlüsselwort definiert werden. Ein Error-Typ wird deklariert, indem dem Basistypen der Name des zugehörigen Error-Sets, gefolgt von einem `!`, vorangestellt wird. Angenommen eine Funktion gibt potenziell einen Fehler aus dem Error-Set `MyErrors` oder `void` (kein Rückgabewert) zurück, dann kann der Rückgabewert der Funktion wie folgt geschrieben werden: `MyErrors!void`. Um einen Error zurück zu geben kann der entsprechende Error-Wert, genau wie andere Rückgabewerte, mit `return` an die aufrufende Funktion gereicht werden.

#code(
```zig
const std = @import("std");

const MyErrors = error{
    IsNotEight,
};

/// Check if the given number is eight.
/// Returns an error if `n` is not equal 8!
fn checkNumber(n: u8) MyErrors!void {
    if (n != 8) return MyErrors.IsNotEight;
}

test "Error test #1" {
    try std.testing.expectError(MyErrors.IsNotEight, checkNumber(7));
}
```,
caption: [chapter02/errors.zig])

Da den gleichen Error-Bezeichnern der gleiche numerische Wert zugewiesen wird, kann im obigen Beispiel anstelle von `MyErrors.IsNotEight` auch `error.IsNotEight` zurückgegeben werden. Zig erlaubt mit der Syntax `error.<NameDesErrors>` die Definition von Errors innerhalb eines impliziten Error-Sets. Dies ist die Kurzform für `(error{<NameDesErrors>}).<NameDesErrors>`.

#code(
```zig
fn checkNumber(n: u8) MyErrors!void {
    if (n != 8) return error.IsNotEight;
}
```
)

=== Error-Set Coercion

Angenommen es existieren zwei Error-Sets, wobei das eine Error-Set eine Teilmenge des Anderen darstellt. In einem solchen Fall erlaubt Zig die Coercion, das heißt das Umwandeln, von der Tielmenge in die Obermenge.

#code(
```zig
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

fn coerce(err: AllocationError) FileOpenError {
    return err;
}

test "Error-Set Coercion" {
    try std.testing.expect(FileOpenError.OutOfMemory == coerce(AllocationError.OutOfMemory));
}
```,
caption: [chapter02/errors.zig])

Was jedoch nicht funktioniert ist die Umwandlung einer Obermenge in eine Teilmenge!

=== Globales Error-Set

Zig erlaubt es das explizite Error-Set links vom `!` wegzulassen, zum Beispiel `!void`. In diesem Fall ist das Error-Set implizit `anyerror`, das globalen Error-Set, dem alle Errors der gesamten Compilation-Unit angehören. Jedes Error-Set kann in `anyerror` umgewandelt werden. Außerdem kann eine Element aus dem globalen Error-Set explizit in ein nicht globales Error-Set ge-castet werden.

#code(
```zig
fn checkNumber(n: u8) !void {
    if (n != 8) return error.IsNotEight;
}
```
)

Im obigen Beispiel wird der Rückgabewert automatisch in einen Wert vom Typ `anyerror!void` umgewandelt.

=== catch

Mit `catch` können Errors, die von einer Funktion zurückgegeben werden, abgefangen und entsprechend behandelt werden.

#code(
```zig
pub fn main() void {
    const n = 7;
    checkNumber(n) catch |e| {
        std.log.err("The number {d} is not equal 8: {any}", .{ n, e });
    };
}
```,
caption: [chapter02/errors.zig])

Das `catch` folgt direkt hinter dem Aufruf der Funktion. Optional kann der Fehler-Wert an eine Variable (im obigen Fall `e`) gebunden werden. Der `catch`-Block (eingegrenzt durch geschweifte Klammern `{}`) wird nur ausgeführt, falls die Funktion einen Error als Rückgabewert liefert.

`catch` eignet sich ebenfalls um im Fehlerfall einen Default-Wert bereitzustellen.

#code(
```zig
test "Default-Wert" {
    const n = std.fmt.parseInt(u64, "0xdeaX", 16) catch 16;
    try std.testing.expect(n == 16);
}
```,
caption: [chapter02/errors.zig])

In diesem Beispiel ist `n` entweder gleich dem entpackten Rückgabewert von `parseInt()` oder, falls `parseInt()` einen Error zurück gibt, 16. Wie zu sehen ist muss nicht zwangsläufig ein Block auf `catch` folgen, genauso zulässig ist ein Ausdruck. Der entpackte Rückgabewert der Funktion und der Ausdruck rechts vom `catch` müssen den selben Typ besitzen (in diesem Beispiel `u64`). 

Alternativ kann auch ein Block mit einem frei wählbaren Bezeichner (zum Beispiel `blk`) verwendet werden. Der Bezeichner muss dabei die selben Anforderungen wie ein Variablen-Name erfüllen.

#code(
```zig
const n = std.fmt.parseInt(u64, "0xdeaX", 16) catch blk: {
    break :blk 16; 
}
try std.testing.expect(n == 16);
```
)

Mittels `break` kann der Default-Wert `16` in den umschließenden Block gereicht werden, wo er an die Konstante `n` gebunden wird. Das Literal wird dabei automatisch vom Typ `comptime_int` in einen `u64` umgewandelt.

=== try

In vielen Fällen reicht es aus, beim Auftreten eines Errors, selbst einen Error an die aufrufende Funktion zurückzugeben. Dies wird als Fehler-Propagierung bezeichnet und kann in Zig durch die Verwendung von `try` umgesetzt werden. Hierzu wird vor den Aufruf einer Funktion, die einen Fehler-Typen als Rückgabetyp besitzt, das Schlüsselwort `try` gesetzt.

#code(
```zig
fn foo(str: []const u8) !void {
    const n = try std.fmt.parseInt(u64, str, 16);
    _ = n;
}
```
)

Das Schlüsselwort `try` evaluiert den zugehörigen Ausdruck und kehrt im Fehlerfall mit dem selben Error aus der Funktion zurück. Andernfalls wird der Rückgabewert der aufgerufenen Funktion entpackt.

Dies ist die Kurzform für den folgenden Code:

#code(
```zig
fn foo(str: []const u8) !void {
    const n = std.fmt.parseInt(u64, str, 16) catch |e| return e;
    _ = n;
}
```
)
