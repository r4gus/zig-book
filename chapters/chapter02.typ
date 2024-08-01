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

== Ganzzahlen (Integer)

Zig unterstützt Ganzzahlen mit einer beliebigen Bitbreite. Der Bezeichner eines jeden Integer-Typen beginnt mit einem Buchstaben `i` (vorzeichenbehaftet; signed) oder `u` (vorzeichenunbehaftet; unsigned) gefolgt von einer oder mehreren Ziffern, welche die Bitbreite in Dezimal darstellen. Als Beispiel, `i7` ist eine vorzeichenbehaftete Ganzzahl der sieben Bit zur Kodierung der Zahl zur Verfügung stehen. Die Aussage, dass die Bitbreite beliebig ist entspricht dabei nicht ganz der Wahrheit. Die maximal erlaubte Bitbreite beträgt $2^16 - 1 = 65535$. 

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

Zur Compile-Zeit bekannte Literale vom Typ `comptime_int` haben kein Limit was ihre Größe (in Bezug auf die Bitbreite) und konvertieren zu anderen Integertypen, solange das Literal im Wertebereich des Typen liegt.

```zig
// Variable `i` vom Typ `comptime_int`
var i = 0;
```

Um die Variable zur Laufzeit modifizieren zu können, muss ihr eine expliziter Type mit fester Bitbreite zugewiesen werden. Dies kann auf zwei weisen erfolgen.

1. Deklaration der Variable `i` mit explizitem Typ, z.B. `var i: usize = 0`.
2. Verwendung der Funktion `@as()`, von welcher der Compiler den Type der Variable `i` ableiten kann, z.B. `var i = @as(usize, 0)`.

Ein häufiger Fehler, der aber schnell behoben ist, ist die Verwendung einer Variable vom Typ `comptime_int` in einer Schleife.

```zig
var i = 0;
while (i < 100) : (i += 1) {}
```

Was zu einem entsprechenden Fehler zur Compilezeit führt.

```bash
$ zig build-exe chapter02/integer.zig
error: variable of type 'comptime_int' must be const or comptime
    var i = 0;
        ^
note: to modify this variable at runtime, it must be given an explicit fixed-size number type
```

Der Zig-Compiler ist dabei hilfreich, indem er neben dem Fehler auch einen Lösungsansatz bietet. Nachdem der Variable `i` ein expliziter Typ zugewiesen wird (`var i: usize`) compiliert das Programm ohne weitere Fehler.

Optional können die Prefixe `0x`, `0o` und `0b` an ein Literal angehängt werden um Literale in Hexadezimal, Octal oder Binär anzugeben, z.B. `0xcafebabe`.

Um größere Zahlen besser lesbar zu machen, kann ein Literal mit Hilfe von Unterstrichen aufgeteilt werden, z.B. `0xcafe_babe`.

Operatoren wie `+` (Addition), `-` (Subtraktion), `*` (Multiplikation) und `/` (Division) führen bei einem Überlauf zu undefiniertem Verhalten (engl. undefined behavior). Aus diesem Grund stellt Zig spezielle Versionen dieser Operatoren zur Verfügung, darunter:

- Operatoren für Sättigungsarithmetik: Alle Operationen laufen in einem festen Intervall zwischen einem Minimum und einem Maximum ab welches nicht unter- bzw. überschritten werden kann.
    - Addition (`+|`): `@as(u8, 255) +| 1 == @as(u8, 255)`
    - Subtraktion (`-|`): `@as(u32, 0) -| 1 == 0`
    - Multiplikation (`*|`): `@as(u8, 200) *| 2 == 255`
- Wrapping-Arithmetik: Dies ist äquivalent zu modularer Arithmetik.
    - Addition (`+%`): `@as(u32, 0xffffffff) +% 1 == 0`
    - Subtraktion (`-%`): `@as(u8, 0) -% 1 == 255`
    - Multiplikation (`*%`): `@as(u8, 200) *% 2 == 144` 
    

== Fließkommazahlen (Float)

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

Literale sind immer vom Typ `comptime_float`, welcher äquivalent zum größtmöglichen Fließkommatypen (`f128`) ist, und können zu jedem beliebigen Fließkommatypen konvertiert werden. Enthält ein Literal keinen Bruchteil, so ist eine Konvertierung zu einem Integertyp ebenfalls möglich.

```zig
const fp = 123.0E+77;
const hfp = 0x103.70p-5;
```

Der Typ `f32` entspricht dem Typ `float` (single precision) in C, während `f64` dem Typ `double` (double precision) entspricht. Je nach Prozessortyp stehen dedizierte Maschineninstruktionen für zumindest einen Teil der Typen zur Verfügung, was eine effizientere Verwendung ermöglicht. Auf _x86\_64_ Prozessor stehen z.B. Instruktionen für single und double Precision zur Verfügung.

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

Aufgrund der Darstellung von Fließkommazahlen kann sich die Ausführung bestimmter Operationen, wie ein Tests auf Gleichheit (`==`), als trickreich herausstellen. Ein Beispiel ist die wiederholte Addition der Fließkommazahl $0.1$. Die Summe $sum_(k=1)^10 0.1$ ist erwartungsgemäß $1.0$, je nach Präzision der Fließkommazahl gilt jedoch $sum_(k=1)^10 0.1 eq.not 1.0$. 

== Arrays und Slices

Zig besitzt eine Vielzahl an Datentypen um eine (lineare) Sequenz an Werten im Speicher darzustellen, darunter:

- Der Typ `[N]T` repräsentiert ein Array vom Typ `T` bestehend aus `N` Werten. Die Größe eines Arrays ist zur Compilezeit bekannt und Arrays werden grundsätzlich auf dem Stack alloziert. Damit kann ein Array weder erweitert noch verkleinert werden.
- Der Typ `[]T` bzw. `[]const T` repräsentiert ein Slice vom Typ `T`, bestehend aus einem Zeiger und einer Länge. Die Länge eines Slices ist zur Laufzeit bekannt. Slices referenzieren eine Sequenz von Werten. Dies kann z.B. ein Array sein oder auch eine auf dem Heap gespeicherte Sequenz. Die von einem konstanten Slice `[]const T` referenzierten Werte können gelesen, jedoch nicht verändert werden, während die Werte eines Slices `[]T` sowohl gelesen als auch verändert werden können.

Sowohl Arrays als auch Slices erlauben den Zugriff auf deren Länge durch den Ausdruck `.len`.

```zig
// chapter02/slices.zig
var a = [_]u8{ 1, 2, 3, 4 };
std.log.info("length of a is {d}", .{a.len});
const s = &a;
std.log.info("length of a is still {d}", .{s.len});
```

Mit dem Address-Of Operator `&` kann ein Slice für ein Array erzeugt werden. Alternativ kann auch der Ausdruck `a[0..]` verwendet werden, der einen Bereich innerhalb des Arrays beschreibt. Grundsätzlich liegt das erste Element einer Sequenz immer an Index $0$ und es kann mit `a[0]` auf dieses zugegriffen werden. Das letzte Element liegt immer an der Stelle `a.len - 1` und es kann mit `a[a.len - 1]` darauf zugegriffen werden. Der Index muss dabei immer ein Integer vom Typ `usize` oder ein Literal sein, das zu diesem Typ konvertiert werden kann. Die Verwendung anderer Typen als Index führt zu einem Fehler zur Compilezeit.

Auf den Zeiger eines Slices kann mit `.ptr` zugegriffen werden, z.B. `s.ptr`.

Zig überprüft bei dem Zugriff auf eine Array oder Slice zur Laufzeit, dass der Index innerhalb des Speicherbereichs der Sequenz liegt. Ließt eine Anwendung über die Grenzen der Sequenz, so führt dies zu einem Fehler zur Laufzeit der den Prozess beendet. Dies verhindert typische Speicherfehler wie Buffer-Overflows and Buffer-Overreads die in Sprachen wie C weit verbreitet sind und in der Vergangenheit zu Hauf von Angreifern ausgenutzt wurden um Anwendungen zu exploiten.

```zig
// chapter02/slices.zig
var i: usize = 0;
while (true) : (i += 1) {
    a[i] += 1;
}
```

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

```zig
const prime: [5]u8 = .{2, 3, 5, 7, 11}; 
const names = [3][]const u8{"David", "Franziska", "Sarah"};
```

Für den Fall, dass initial keine Werte bekannt sind kann ein Array mit `undefined` initialisiert werden. In diesem Fall ist der Inhalt des Speichers undefiniert.

```zig
const some: [1000]u8 = undefined;
```

Arrays können aber auch mit einem bestimmten Wert initialisiert werden. Im unteren Beispiel wird das gesamte Array mit `0` Werten initialisiert.

```
const some: [1000]u8 = .{0} ** 1000;
```

Die Länge eines Arrays muss immer zur Compilezeit bekannt sein. Dementsprechend können keine Variablen zur Angabe der Länge verwendet werden, außer die Variable ist vom Typ `comptime_int`. Sollte ein Array benötigt werden, dessen Länge nur zur Laufzeit bekannt ist, so muss der Speicher entweder manuell alloziert oder auf einen Kontainertypen wie `ArrayList` aus der Standardbibliothek zurückgegriffen werden #footnote[Mehr dazu in folgenden Kapiteln.].

Viel Funktionen die über Sequenzen arbeiten erwarten ein Slice und kein Array. Zig konvertiert dabei nicht automatisch Arrays zu Slices, d.h. bei einem Aufruf muss explizit der Address-Of Operator `&` auf das Array angewandt werden oder alternativ ein Slice mit dem `[]` Operator festgelegt werden.

```zig
// chapter02/coersion.zig
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
```

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

```zig
// github.com/ziglang/zig/src/mutable_value.zig
pub const Slice = struct {
    ty: InternPool.Index, // wir ignorieren dieses Feld :)
    /// Must have the appropriate many-ptr type.
    ptr: *MutableValue,
    /// Must be of type `usize`.
    len: *MutableValue,
};
```

Je nach Typ einer Variable bzw. eines Parameters konvertiert Zig die Referenz zu einem Struct automatisch in ein Slice.

```zig
const b: [3][]const u8 = .{ "David", "Franziska", "Sarah" };

// Zig konvertiert die Referenz automatisch zu einem Slice.
const sb: []const []const u8 = &b;
_ = sb;

// `rb` ist ein Pointer zu einem Array.
const rb: *const [3][]const u8 = &b;
_ = rb;
```

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

```zig
const name = "David";
// Die ersten drei Buchstaben
std.log.info("{s}", .{name[0..3]});
// Die letzten zwei Buchstaben
std.log.info("{s}", .{name[3..]});
// Die mittleren drei Buchstaben
std.log.info("{s}", .{name[1..4]});
```

Um Buffer-Overreads vorzubeugen überprüft Zig, dass die angegeben Indices valide sind. Sind die Indices zur Compilezeit bekannt, so führt ein invalider Index zu einem Compile-Fehler, andernfalls zu einer Panic zur Laufzeit.

```zig
// chapter02/slice_error.zig
const a = "this won't work";
// ...
const n: usize = 20;
std.log.info("{s}", .{a[1..n]});
```

Versucht man den obigen Code mit *`zig build-exe chapter02/slice_error.zig`* zu Compilieren so erhält man den folgenden Fehler:

```bash
error: end index 20 out of bounds for array of length 15 +1 (sentinel)
    std.log.info("{s}", .{a[1..n]});
```

== Container

Jedes syntaktische Konstruct in Zig welches als Namensraum dient und Variablen- oder Funktionsdeklaraionen umschließt wird als Container bezeichnet. Weiterhin können Container selbst Typdeklarationen sein, welche instantiiert werden können. Dazu zählen `struct`s, `enum`s, `union`s und sogar Sourcedateien.

Ein Merkmal welches Container von Blöcken unterscheidet ist, dass Container keine Ausdrücke enthalten, obwohl sowohl Container als auch Blöcke, mit der Ausnahme von Sourcedateien, in geschweifte Klammern (`{}`) gefasst werden.

=== Struct

In Zig werden Structs mit dem `struct` Schlüsselwort deklariert. Der Inhalt eines Structs wird dabei in geschweifte Klammern gefasst. Neben Feldern können Structs auch Methoden, Konstanten und Variablen enthalten.

```zig
const RgbColor = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0, 

    const RED = @This(){ .r = 255 };
    const GREEN = @This(){ .g = 255 };
    const BLUE = @This(){ .b = 255 };

    pub fn add(self: *@This(), other: *@This()) @This() {
        // TODO 
    }
};
```

Jedes Feld wird durch einen Bezeichner und einen Typ, getrennt durch einen Doppelpunkt `:`, angegeben. Weiterhin kann jedem Feld ein Default-Wert zugewiesen werden, der automatisch übernommen wird, sollte beim Instanziieren des Structs kein Wert für das Feld angegeben werden.

```zig
const red = RgbColor{ .r = 255 };
```

Mit Hilfe der Funktion `@This()` kann auf den umschließenden Kontext, im obigen beispiel das Struct, welches an `RgbColor` #footnote[Die gängige Konvention ist, dass Typbezeichner Camel-Case verwenden, d.h. ein zusammengeschriebenes Wort beginnend mit einem Großbuchstaben.] gebunden wird, zugegriffen werden.

Konstanten innerhalb von Structs können dazu verwendet werden um Werte, wie etwa die Länge eines kryptografischen Schlüssels oder wie oben zu sehen, gängige Farben, die im Bezug zu dem gegeben Struct stehen im selben Scope zu deklarieren.


=== Enum

=== Union

