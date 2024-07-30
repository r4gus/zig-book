#import "../tip-box.typ": tip-box

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

