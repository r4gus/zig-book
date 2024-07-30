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

  [`u8`],
  [$0$ bis $2^8 - 1$],

)

Vorzeichenbehaftete Ganzzahlen werden im Zweierkomplement dargestellt #footnote[https://en.wikipedia.org/wiki/Two's_complement]. In Assembler wird nicht zwischen vorzeichenbehafteten und vorzeichenunbehafteten Zahlen unterschieden. Alle mathematischen Operationen werden von der CPU auf Registern, mit einer festen Bitbreite (meist 64 Bit auf modernen Computern), ausgeführt. Dabei entspricht jede, vom Computer ausgeführte, arithmetische Operationen effektiv einem "Rechnen mit Rest", auch bekannt als modulare Arithmetik #footnote[https://de.wikipedia.org/wiki/Modulare_Arithmetik]. Die Bitbreite $m$ der Register (z.B. 64) repräsentiert dabei den Modulo $2^m$. Damit entspricht ein 64 Bit Register dem Restklassenring $ZZ_(2^64) = {0, 1, 2, ..., 2^64 - 1}$ und jegliche Addition zweier Register resultiert in einem Wert der ebenfalls in $ZZ_(2^64)$ liegt, d.h. auf _x86\_64_ wäre die Instruktion `add rax, rbx` äquivalent zu $"rax" = "rax" + "rbx" "mod" 2^64$. Diese Verhalten überträgt sich analog auf Ganzzahlen in Zig.

Das Zweierkomplement einer Zahl $a in ZZ_m$ ist das additive Inverse $a'$ dieser Zahl, d.h. $a + a' equiv 0$. Dieses kann mit $a' = m - a$ berechnet werden. Für `i8` wäre das additive Inverse zu $a = 4$ die Zahl $a' = 2^8 - 4 = 256 - 4 = 252$. Addiert man beide Zahlen modulo $256$, so erhält man wiederum das neutrale Element $0$, $a + a' mod 256 = 4 + 252 mod 256 = 256 mod 256 = 0$. Das Zweierkomplement hat seinen Namen jedoch nicht von der Subtraktion, sondern von der speziellen Weise wie das additive Inverse einer Zahl bestimmt wird. Dieser Vorgang kann wie folgt beschrieben werden:

1. Gegeben eine Zahl in Binärdarstellung, invertiere jedes Bit, d.h. jede $1$ wird zu einer $0$ und umgekehrt.
2. Addiere $1$ auf das Resultat und ignoriere mögliche Überläufe.

Für das obige Beispiel mit der Zahl $4$ sieht dies wie folgt aus:
$
00000100_2 &= 4_16 && "invertiere alle Bits der Zahl 4" \
11111011_2 &= 251_16 && "addiere 1 auf die Zahl 251" \
11111100_2 &= 252_16
$

#tip-box([
    Zur Compile-Zeit bekannte Ganzzahlen haben kein Limit was ihre Größe (in Bezug auf die Bitbreite) angeht.
])

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

