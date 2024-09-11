#import "../tip-box.typ": tip-box

= Zig Crash Course

In diesem Kapitel schauen wir uns einige kleine Zig Programme an, damit Sie ein Gespür für die Programmiersprache bekommen. Machen Sie sich nicht zu viele Sorgen wenn Sie nicht alles sofort verstehen, in den folgenden Kapiteln werden wir uns mit den hier vorkommenden Konzept noch näher beschäftigen. Wichtig ist, dass Sie diese Kapitel nicht nur lesen sondern die Beispiel auch ausführen, um das meiste aus diesem Kapitel herauszuholen.

== Zig installieren

Um Zig zu installieren besuchen Sie die Seite #link("https://ziglang.org") und folgen den Instruktionen unter "GET STARTED" #footnote[https://ziglang.org/learn/getting-started/].

Die Installation ist unter allen Betriebssystemen relativ einfach durchzuführen. In der Download Sektion #footnote[https://ziglang.org/download/] finden Sie vorkompilierte Zig-Compiler für die gängigsten Betriebssysteme, darunter Linux, macOS und Windows. 

Unter Linux können Sie mit dem Befehl *`uname -a`* Ihre Architektur bestimmen. In meinem Fall ist dies `X86_64`.

```bash
$ uname -a
Linux ... x86_64 x86_64 x86_64 GNU/Linux
```

Die Beispiele in diesem Buch basieren auf der Zig-Version 0.13.0, d.h. um den entsprechenden Compiler auf meinem Linux system zu installieren würde ich die Datei _zig-linux-x86\_64-0.13.0.tar.xz_ aus der Download-Sektion herunterladen.

#figure(
  image("../images/chapter01/zig-versions.png", width: 80%),
  caption: [
    Download Seite von #link("https://ziglang.org/download/")
  ],
)

Mit dem _tar_ Kommandozeilenwerkzeug kann das heruntergeladene Archiv danach entpackt werden.

```bash
$ tar -xf zig-linux-x86_64-0.13.0.tar.xz
```

Der entpackte Ordner enthält die Folgenden Dateien.

```bash
$ ls zig-linux-x86_64-0.13.0
doc  lib  LICENSE  README.md  zig
```

- *doc*: Die Referenzdokumentation der Sprache. Diese ist auch online, unter #link("https://ziglang.org/documentation/0.13.0/"), zu finden und enthält einen Überblick über die gesamte Sprache. Ich empfehle Ihnen ergänzend zu diesem Buch die Dokumentation zu Rate zu ziehen.
- *lib*: Enthält alle benötigten Bibliotheken, inklusive der Standardbibliothek. Die Standardbibliothek enthält viel nützliche Programmbausteine, darunter geläufige Datenstrukturen, einen JSON-Parser, Kompressionsalgorithmen, kryptographische Algorithmen und Protokolle und vieles mehr. Eine Dokumentation der gesamten Standardbibliothek findet sich online  unter #link("https://ziglang.org/documentation/0.13.0/std/").
- *zig*: Dies ist ein Kommandozeilenwerkzeug mit dem unter anderem Zig-Programme kompiliert werden können.

Um den Zig-Compiler nach dem Entpacken auf einem Linux System zu installieren, können wir diesen nach _/usr/local/bin_ verschieben.

```bash
$ sudo mv zig-linux-x86_64-0.13.0 /usr/local/bin/zig-linux-x86_64-0.13.0
```

Danach erweitern wir die `$PATH` Umgebungsvariable um den Pfad zu unserem Zig-Compiler. Dies können wir in der Datei _\~/.profile_ oder auch _\~/.bashrc_ machen #footnote[Je nach verwendetem Terminal kann die Konfigurationsdatei auch anders heißen.].

```
# Sample .bashrc for SuSE Linux

# ...

export PATH="$PATH:/usr/local/bin/zig-linux-x86_64-0.13.0"
```

Nach Änderung der Konfigurationsdatei muss diese neu geladen werden. Dies kann entweder durch das öffnen eines neuen Terminalfensters erfolgen oder wir führen im derzeitigen Terminal das Kommando *`source .bashrc`* in unserem Home-Verzeichnis aus. Danach können wir zum überprüfen, ob alles korrekt installiert wurde, das Zig-Zen auf der Kommandozeile ausgeben lassen. Das Zig-Zen kann als die Kernprinzipien der Sprache und ihrer Community angesehen werden, wobei man dazu sagen muss, dass es nicht "die eine" Community gibt.

```bash
$ source ~/.bashrc
$ zig zen

 * Communicate intent precisely.
 * Edge cases matter.
 * Favor reading code over writing code.
 * Only one obvious way to do things.
 * Runtime crashes are better than bugs.
 * Compile errors are better than runtime crashes.
 * Incremental improvements.
 * Avoid local maximums.
 * Reduce the amount one must remember.
 * Focus on code rather than style.
 * Resource allocation may fail; 
     resource deallocation must succeed.
 * Memory is a resource.
 * Together we serve the users.
```

Mit dem Kommando *`zig help`* lässt sich ein Hilfetext auf der Kommandozeile anzeigen, der die zu Verfügung stehenden Kommandos auflistet.

Praktisch ist, dass Zig für uns ein neues Projekt, inklusive Standardkonfiguration, anlegen kann.

```bash
$ mkdir hello && cd hello
$ zig init
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
info: see `zig build --help` for a menu of options
```

Das Kommando initialisiert den gegebenen Ordner mit Template-Dateien, durch die sich sowohl eine Executable, als auch eine Bibliothek bauen lassen. Schaut man sich die erzeugten Dateien an so sieht man, dass Zig eine Datei namens _build.zig_ erzeugt hat. Bei dieser handelt es sich um die Konfigurationsdatei des Projekts. Sie beschreibt aus welchen Dateien eine Executable bzw. Bibliothek gebaut werden soll und welche Abhängigkeiten (zu anderen Bibliotheken) diese besitzen. Ein bemerkenswertes Detail ist dabei, dass _build.zig_ selbst ein Zig Programm ist, welches in diesem Fall zur Compile-Zeit ausgeführt wird um die eigentlichle Anwendung zu bauen.

Die Datei _build.zig.zon_ enthält weitere Informationen über das Projekt, darunter dessen Namen, die Versionsnummer, sowie mögliche Dependencies. Dependencies können dabei lokal vorliegen und über einen relativen Pfad angegeben oder von einer Online-Quelle, wie etwa Github, bezogen werden. Die Endung der Datei steht im übrigen für Zig Object Notation (ZON), eine Art Konfigurationssprache für Zig, die derzeit, genauso wie Zig selbst, noch nicht final ist.

Schauen wir in _src/main.zig_, so sehen wir das Zig für uns ein kleines Programm geschrieben hat.

```zig
const std = @import("std");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}
```

Der Code kann auf den ersten Blick überwältigend wirken, schauen wir ihn uns deswegen Stück für Stück an.

```zig
const std = @import("std");
```

Mit der `@import()` Funktion importieren wir die Standardbibliothek (`std`) und binden diese an eine Konstante mit dem selben Namen.
Die Standardbibliothek ist eine Ansammlung von nützlichen Funktionen und Datentypen, die während der Entwicklung von Anwendungen
häufiger zum Einsatz kommen und deswegen vom Zig zur Verfügung gestellt werden. Die Funktion `@import()` wird nicht nur zum importieren
der Standardbibliothek verwendet, sondern auch um auf Module und andere, zu einem Projekt gehörende, Quelldateien zuzugreifen.

Nach der Definition der Konstante `std` beginnt die `main` Funktion:

```zig
pub fn main() !void {
```

Unsere `main` Funktion beginnt, wie alle Funktionen, mit `fn` und dem Namen der Funktion. Sie gibt keinen Wert zurück, aus diesem Grund folgt auf die leere Parameterliste `()` der Rückgabetyp `void`. Das Ausrufezeichen `!` weist darauf hin, das die Funktion einen Fehler zurückgeben kann. Fehler in Zig sind eigenständige Werte, die von einer Funktion zurückgegeben werden können und sich semantisch vom eigentlichen Rückgabewert unterscheiden.

```zig
std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
```

Als erstes gibt die `main` Funktion einen String über die Debugausgabe auf der Kommandozeile aus. Die Funktion `print` erwartet dabei einen Format-String, der mit Platzhaltern (z.B. `{s}`) versehen werden kann, sowie eine Liste an Ausdrücken (z.B. `.{"codebase"}`) deren Werte in den String eingefügt werden sollen. Der Platzhalter `{s}` gibt z.B. an, dass an der gegebenen Stelle ein String eingefügt werden soll. Neben `s` gibt es unter anderem noch `d` für Ganzzahlen und `any` für beliebige werte. 

```zig
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();
```

Via `std.io` können wir mit `getStdIn()`, `getStdOut()` und `getStdErr()` auf `stdin`, `stdout` und `stderr` zugreifen. Alle drei Funktionen geben jeweils eine Objekt vom Typ `File` zurück. Die Funktion `writer()` welche auf der stdout-Datei aufgerufen wird, gibt einen `Writer` zurück. Ein `Writer` ist ein Wrapper um einen beliebiges Datenobjekt (z.B. eine offene Datei, ein Array, ...) und stellt eine standartisiertes Interface zur Verfügung um Daten zu serialisieren. In unserem Fall wird der `stdout_file` Writer wiederum in einen `BufferedWriter` gewrapped, welcher nicht bei jedem einzelnen Schreibvorgang auf die Datei `stdout` zugreift, sondern erst wenn genug Daten geschrieben wurden bzw. wenn die Funktion `flush()` aufgerufen wird. Die Konstante `stdout` ist also ein `Writer` der einen `Writer` umschließt, der eine Datei umschließt, in die schlussendlich geschrieben werden soll.

```zig
try stdout.print("Run `zig build test` to run the tests.\n", .{});
```

Der `BufferedWriter` (`stdout`) wird verwendet um (indirekt) den String "Run zig build test to run the tests." nach stdout (standardmäßig die Kommandozeile) zu schreiben. Da diese Schreiboperation fehlschlagen kann wird vor den Ausdruck ein `try` gestellt. Damit wird ein potenzieller Fehler "nach oben" propagiert, was im gegebenen Fall zu einem Programmabsturz führen würde, da `main` keine Funktion über sich besitzt. Als Alternative könnte mit einem `catch` Block der Fehler explizit abgefangen werden.

```zig
try bw.flush();
```

Um sicher zu gehen, dass auch alle Daten aus dem `BufferedWriter` tatsächlich geschrieben wurden, muss schlussendlich `flush()` aufgerufen werden.

Das von Zig vorbereitete "Hello, World"-Programm kann mit *`zig build run`*, von einem beliebigen Ordner innerhalb des Zig-Projekts, ausgeführt werden.

```bash
$ zig build run
All your codebase are belong to us.
Run `zig build test` to run the tests.
```

Im gegebenen Beispiel wurden zwei Schritte ausgeführt. Zuerst wurde der Zig-Compiler aufgerufen um das Programm in _src/main.zig_ zu kompilieren und im zweiten Schritt wurde das Programm ausgeführt. Zig platziert dabei seine Kompilierten Anwendungen in _zig-out/bin_ und Bibliotheken in _zig-out/lib_.

== Funktionen

Zig's Grammatik ist sehr überschaubar und damit leicht zu erlernen. Diejenigen mit Erfahrung in anderen C ähnlichen Programmiersprachen wie C, C++, Java oder Rust sollten sich direkt Zuhause fühlen. Die unterhalb abgebildete Funktion berechnet den größten gemeinsamer Teiler (greatest common divisor) zweier Zahlen.

```zig
// chapter01/gcd.zig
fn gcd(n: u64, m: u64) u64 {
    return if (n == 0)
        m
    else if (m == 0)
        n
    else if (n < m)
        gcd(m, n)
    else
        gcd(m, n % m);
}
```

Das `fn` Schlüsselwort markiert den Beginn einer Funktion. Im gegebenen Beispiel definieren wir eine Funktion mit dem Name `gcd`, welche zwei Argumente `m` und `n`, jeweils vom Typ `u64`, erwartet. Nach der Liste an Argumenten in runden Klammern folgt der Typ des erwarteten Rückgabewertes. Da die Funktion den größten gemeinsamen Teiler zweier `u64` Ganzzahlen berechnet ist auch der Rückgabewert vom Typ `u64`. Der Körper der Funktion wird in geschweifte Klammern gefasst.

Zig unterscheidet zwischen zwei Variablen-Typen, Variablen und Konstanten. Konstanten können nach ihrer Initialisierung nicht mehr verändert werden, während Variablen neu zugewiesen werden können. Funktionsargumente zählen grundsätzlich zu Konstanten, d.h. sie können nicht verändert werden. Der Zig-Compiler erzwingt die Nutzung von Konstanten, sollte eine Variable nach ihrer Initialisierung nicht mehr verändert werden. Dies ist eine durchaus kontroverse Designentscheidung, welche aber auf das Zig-Zen zurückgeführt werden kann, das besagt: ,,Favor reading code over writing code". Sollten Sie also eine Variable in fremden Code sehen so können Sie sicher sein, dass diese an einer anderen Stelle manipuliert bzw. neu zugewiesen wird.

Eine Besonderheit, die Zig von anderen Sprachen unterscheidet ist, dass Integer mit beliebiger Präzision unterstützt werden. Im obigen Beispiel handelt es sich bei `u64` um eine vorzeichenlose Ganzzahl (unsigned integer) mit 64 Bits, d.h. es können alle Zahlen zwischen 0 und $2^64 - 1$ dargestellt werden. Zig unterstützt jedoch nicht nur `u8`, `u16`, `u32` oder `u128` sondern alle unsigned Typen zwischen `u0` und `u65535`.

#tip-box([
Alle Zig-Basistypen sind Teil des selben `union`: std.builtin.Type. Das union beinhaltet den `Int` Typ welcher ein `struct` mit zwei Feldern ist, `signedness` und `bits`, wobei `bits` vom Typ `u16` ist, d.h. es können alle Integer-Typen zwischen 0 und $2^16 - 1$ Bits verwendet werden. Ja Sie hören richtig, der Zig-Compiler ist seit Version 0.10.0 selbst in Zig geschrieben, d.h. er ist self-hosted.
])



Innerhalb des Funktonskörpers werden mittels `if` verschiedene Bedingungen abgefragt. Sollte eine beider Zahlen 0 sein, so wird jeweils die andere zurückgegeben, ansonsten wird `gcd` rekursiv aufgerufen bis für eine der beiden Zahlen die Abbruchbedingung ($0$) erreicht ist. Wie auch bei C muss die Bedingung in runde Klammern gefasst werden. Bei Einzeilern können die geschweiften Klammern um einen Bedingungsblock weggelassen werden. In diesem Fall wird der Rückgabewert der Bedingung an den umschließenden Block gereicht.

Mittels eines `return` Statements kann von einer Funktion in die aufrufende Funktion zurückgekehrt werden. Das Statement nimmt bei bedarf zusätzlich einen Wert der an die aufrufende Funktion zurückgegeben werden soll. Im obigen Beispiel gibt `gcd` mittels `return` den Wert des ausgeführten If-Else-Asudruck zurück.

Das vollständige Programm finden Sie im zugehörigen Github-Rerpository. Mittels *`zig build-exe chapter01/gcd.zig`* kann das Beispiel kompiliert werden.

== Unit Tests

Wie von einer modernen Programmiersprache zu erwarten bietet Zig von Haus aus Unterstützung für Tests. Tests beginnen mit dem Schlüsselwort `test`, gefolgt von einem String der den Test bezeichnet. In geschweiften Klammern folgt der Test-Block.

```zig
// chapter01/gcd.zig
test "assert that the gcd of 21 and 4 is 1" {
    try std.testing.expectEqual(@as(u64, 1), gcd(21, 4));
}
```

Die Standardbibliothek bietet unter `std.testing` eine ganze Reihe an Testfunktionen für verschiedene Datentypen und Situationen. Im obigen Beispiel verwenden wir `ExpectEqual`, welche als erstes Argument den erwarteten Wert erhält und als zweites Argument das Resultat eines Aufrufs von `gcd`. Die Funktion überprüft beide Werte auf ihre Gleichheit und gibt im Fehlerfall einen `error` zurück. Dieser Fehler kann mittels `try` propagiert werden, wodurch der Testrunner im obigen Beispiel erkennt, dass der Test fehlgeschlagen ist.

```bash
$ zig test chapter01/gcd.zig 
All 1 tests passed.
```

Innerhalb einer Datei sind Definitionen auf oberster Ebene (top-level definitions) unabhängig von ihrer Reihenfolge, was die Definition von Tests mit einschließt. Damit können Tests an einer beliebigen Stelle definiert werden, darunter direkt neben der zu testenden Funktion oder am Ende einer Datei. Der Zig-Test-Runner sammelt automatisch alle definierten Tests und führt dies beim Aufruf von *`zig test`* aus. Worauf Sie jedoch achten müssen ist, dass Sie ausgehend von der Wurzel-Datei (in den meisten Fällen _src/root.zig_), die konzeptionell den Eintritspunkt für den Compiler in ihr Programm oder Ihre Bibliothek darstellt, Zig mitteilen müssen in welchen Dateien zusätzlich nach Tests gesucht werden soll. Dies bewerkstelligen Sie, indem Sie die entsprechende Datei innerhalb eines Tests importieren.

```zig
const foo = @import("foo.zig");

test "main tests" {
    _ = foo; // Tell test runner to also look in foo for tests
}
``` 

== Comptime

Die meisten Sprachen erlauben eine Form von Metaprogrammierung, d.h. das Schreiben von Code der wiederum Code generiert. In C können die gefürchteten Makros mit dem Präprozessor verwendet werden und Rust bietet sogar zwei verschiedene Typen von Makros, jeweils mit einer eigenen Syntax. Zig bietet mit `comptime` seine eigene Form der Metaprogrammierung. Was Zig von anderen kompilierten Sprachen unterscheidet ist, dass die Metaprogrammierung in der Sprache selber erfolgt, d.h., wer Zig programmieren kann, der hat alles nötige Handwerkszeug um auch Metaprogrammierung in Zig zu betreiben.

Ein Aufgabe für die Metaprogrammierung sehr gut geeignet ist, ist die Implementierung von Container-Typen wie etwa `std.ArrayList`. Eine `ArrayList` ist ein Liste von Elementen eines beliebigen Typen, die eine Menge an Standardfunktionen bereitstellt um die Liste zu manipulieren. Nun wäre es sehr aufwändig die `ArrayList` für jeden Typen einzeln implementieren zu müssen. Aus diesem Grund ist `ArrayList` als Funktion implementiert, welche zur Compilezeit einen beliebigen Typen übergeben bekommt auf Basis dessen einen `ArrayList`-Typ generiert. 

```zig
var list = std.ArrayList(u8).init(allocator);
try list.append(0x00);
```

Der Funktionsaufruf `ArrayList(u8)` wird zur Compilezeit ausgewertet und gibt einen neuen Listen-Typen zurück, mit dem sich eine Liste an `u8` Objekten managen lassen. Auf diesem Typ wird `init()` aufgerufen um eine neu Instanz des Listen-Typs zu erzeugen. Mit der Funktion `append()` kann z.B., ein Element an das Ende der Liste angehängt werden. Eine stark simplifizierte Version von `ArrayList` könnte wie folgt aussehen.

```zig
// chapter01/my-arraylit.zig
const std = @import("std");

// Die Funktion erwartet als Compilezeitargument einen Typen `T`
// und gibt ein Struct zurück, dass einen Wrapper um einen Slice
// des Type `T` darstellt.
//
// Der Wrapper implementiert Funktionen zum managen des Slices
// und unterstützt unter anderem:
// - das Hinzufügen neuer Elemente
pub fn MyArrayList(comptime T: type) type {
    return struct {
        items: []T,
        allocator: std.mem.Allocator,

        // Erzeuge eine neue Instanz von MyArrayList(T).
        // Der übergebene Allocator wird von dieser Instanz gemanaged.
        pub fn init(allocator: std.mem.Allocator) @This() {
            return .{
                .items = &[_]T{},
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *@This()) void {
            self.allocator.free(self.items);
        }

        // Füge da Element `e` vom Typ `T` ans ende der Liste.
        pub fn append(self: *@This(), e: T) !void {
            // `realloc()` kopiert die Daten bei Bedarf in den neuen
            // Speicherbereich aber die Allokation kann auch
            // fehlschlagen. An dieser Stelle verbleiben wir der
            // Einfachheit halber bei einem `try`.
            self.items = try self.allocator.realloc(self.items, self.items.len + 1);
            self.items[self.items.len - 1] = e;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var list = MyArrayList(u8).init(allocator);
    defer list.deinit();

    try list.append(0xAF);
    try list.append(0xFE);

    std.log.info("{s}", .{std.fmt.fmtSliceHexLower(list.items[0..])});
}
```

Mit dem `comptime` Keyword sagen wir dem Compiler, dass das Argument `T` zur Compilezeit erwartet wird. Beim Aufruf von `MyArrayList(u8)` wertet der Compiler die Funktion aus und generiert dabei einen neuen Typen. Das praktische ist, dass wir `MyArrayList` nur einmal implementieren müssen und diese im Anschluss mit einem beliebigen Typen verwenden können. 

Der `comptime` Typ `T` kann innerhalb und auch außerhalb des von der Fukntion `MyArrayList` zurückgegebenen Structs, anstelle eines expliziten Typs, verwendet werden. 

Structs die mit `init()` initialisiert und mit `deinit()` deinitialisiert werden sind ein wiederkehrendes Muster in Zig. Dabei erwartet `init()` meist einen `std.mem.Allocator` der von der erzeugten Instanz verwaltet wird.

Ein weiterer Anwendungsfall bei dem Comptime zum Einsatz kommen kann ist die Implementierung von Parsern. Ein Beispiel hierfür ist der Json-Parser der Standardbibliothek (`std.json`), welcher dazu verwendet werden kann um Zig-Typen als Json zu serialisieren und umgekehrt #footnote[Die JavaScript Object Notation (JSON) ist eines der gängigsten Datenformate und wird unter anderem zur Übermittlung von Daten im Web verwendet (#link("https://en.wikipedia.org/wiki/JSON")).].

```zig
// chapter01/reflection.zig
const std = @import("std");

const MyStruct = struct {
    a: u32 = 12345,
    b: []const u8 = "Hello, World",
    c: bool = false,
};

fn isStruct(obj: anytype) bool {
    const T = @TypeOf(obj);
    const TInf = @typeInfo(T);

    return switch (TInf) {
        .Struct => |S| blk: {
            inline for (S.fields) |field| {
                std.log.info("{s}: {any}", .{ field.name, @field(obj, field.name) });
            }

            break :blk true;
        },
        else => return false,
    };
}

pub fn main() void {
    const s = MyStruct{};

    std.debug.print("{s}", .{if (isStruct(s)) "is a struct!" else "is not a struct!"});
}
```

Anstelle eines Typen kann `anytype` für Parameter verwendet werden. In diesem Fall wird der Typ des Parameters, beim Aufruf der Funktion, abgeleitet. Zig erlaubt Reflexion (type reflection). Unter anderem erlaubt Zig die Abfrage von (Typ-)Informationen über ein Objekt. Funktionen denen ein `@` vorangestellt sind heißen Builtin-Function (eingebaute Funktion) und werden direkt vom Compiler bereitgestellt, d.h., sie können überall in Programmen, ohne Einbindung der Standardbibliothek, verwendet werden.

Die Funktion `@TypeOf()` ist insofern speziell, als dass sie eine beliebige Anzahl an Ausdrücken als Argument annimmt und als Rückgabewert den Typ des Resultats zurückliefert. Die Ausdrücke werden dementsprechend evaluiert. Im obigen Beispiel wird `@TypeOf()` genutzt um den Typen des übergebenen Objekts zu bestimmen, da `isStruct()` aufgrund von `anytype` mit einem Objekt beliebigen Typs aufgerufen werden kann.

Die eigentliche Reflexion kann mithilfe der Funktion `@typeInfo()` durchgeführt werden, die zusätzliche Informationen über einen Typ zurückliefert. Felder sowie Deklarationen von `structs`, `unions`, `enums` und `error` Sets kommen dabei in der selben Reihenfolge vor, wie sie auch im Source Code zu sehen sind. Im obigen Beispiel testen wir mittels eines `switch` Statements ob es sich um ein `struct` handelt oder nicht und geben dementsprechend entweder `true` oder `false` zurück. Sollte es sich um ein `struct` handeln, so iterieren wir zusätzlich über dessen Felder und geben den Namen des Felds, sowie dessen Wert aus. Den Wert des jeweiligen Felds erhalten wir, indem wir mittels `@field()` darauf zugreifen. Die Funktion `@field()` erwartet als erstes Argument ein Objekt (ein Struct) und als zweites Argument einen zu Compile-Zeit bekannten String, der den Namen des Felds darstellt, auf das zugegriffen werden soll. Damit ist `@field(s, "b")` das Äquivalent zu `s.b`.

Für jeden Typen, mit dem `isStruct()` aufgerufen wird, wird eine eigene Kopie der Funktion (zur Compile Zeit) erstellt, die an den jeweiligen Typen angepasst ist. Das Iterieren über die einzelnen Felder eines `structs` muss zur Compile Zeit erfolgen, aus diesem Grund nutzt die obige Funktion `inline` um die For-Schleife zu entrollen, d.h., aus der Schleife eine lineare Abfolge von Instruktionen zu machen.

```bash
$ zig build-exe chapter01/reflection.zig
$ ./reflection 
info: a: 12345
info: b: { 72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100 }
info: c: false
```

Reflexion kann in vielen Situationen äußerst nützlich sein, darunter der Implementierung von Parsern für Formate wie JSON oder CBOR #footnote[https://github.com/r4gus/zbor], da im Endeffekt nur zwei Funktionen implementiert werden müssen, eine zum Serialisieren der Daten und eine zum Deserialisieren. Mithilfe von Reflexion kann dann, vom Compiler, für jeden zu serialisierenden Datentyp eine Kopie der Funktionen erzeugt werden, die auf den jeweiligen Typen zugeschnitten ist.

== Kryptographie

Ein Großteil der Anwendungen, die Sie wahrscheinlich täglich verwenden, benutzt in irgend einer Form Kryptographie. Dabei handelt es sich grob gesagt um mathematische Algorithmen, mit denen vorwiegend die Vertraulichkeit (Confidentiality), Integrität (Integrity) und Authentizität (Authenticity) von Daten gewährleistet werden kann. Typische Anwendungsbereiche die Kryptographie verwenden sind Messenger, Video Chats, Networking (TLS), Passwortmanager und Smart Cards. Zig bietet in seiner Standardbibliothek bereits jetzt eine Vielzahl and kryptographischen Algorithmen und Protokollen, wobei ein Großteil davon von Frank Denis #footnote[https://github.com/jedisct1], Online auch bekannt als jedisct1, beigetragen wurde. Ohne groß ein Authoritätsargument aufmachen zu wollen, ist Frank der Maintainer von libsodium #footnote[https://github.com/jedisct1/libsodium] und libhydrogen #footnote[https://github.com/jedisct1/libhydrogen], zwei viel genutzte, kryptographische Bibliotheken.

Wir werden uns in einem späteren Kapitel noch genauer mit Kryptographie auseinandersetzen, machen Sie sich deshalb keine Sorgen, wenn Sie nicht alles in diesem Abschnitt auf Anhieb verstehen. Fürs erste schauen wir uns einen gängigen Anwendungsfall von Kryptographie an, die Verschlüsselung einer Datei. Angenommen wir haben eine Datei deren Inhalt geheim bleiben soll und wir wollen des weiteren überprüfen können, dass der Inhalt der Datei nicht verändert wurde. In solch einem Fall bietet sich die Verwendung eines AEAD (Authenticated Encryption with Associated Data) Ciphers an. Zig bietet unter `std.crypto.aead` verschiedene AEAD Cipher an. Die Unterschiede zwischen den Ciphern ist für dieses Beispiel Out-of-Scope. Sie müssen sich fürs erste damit begnügen mir zu glauben, dass `XChaCha20Poly1305` #footnote[https://datatracker.ietf.org/doc/html/rfc7539] für diese Art von Problem eine gute Wahl ist. Der Name `XChaCha20Poly1305` enthält dabei zwei Informationen, die uns Aufschluss über die Zusammensetzung des Ciphers geben:

- `XChaCha20`: Zur Verschlüsselung der Daten wird die "Nonce-eXtended" Version der `ChaCha20` Stromchiffre verwendet. `XChaCha20` erwartet einen Schlüssel und eine Nonce (Number used once: Eine Byte-Sequenz die nur einmal für eine Verschlüsselung verwendet werden darf) und leitet daraus eine Schlüsselsequenz ab, die mit dem Klartext XORed wird. Die eXtended Version verwendet dabei eine 192-Bit Nonce anstelle einer 96-Bit Nonce, was es deutlich sicherer macht diese zufällig mittels eines (kryptographisch sicheren) Zufallszahlengenerators zu erzeugen. Dieser Teil des Algorithmus ist für die Vertraulichkeit der Daten verantwortlich.
- `Poly1305`: `Poly1305` ist ein Hash, der zur Erzeugung von (one-time) Message Authentication Codes (MAC) verwendet werden kann. MACs sind sogenannte Keyed-Hashfunktionen, bei denen in einen Hash (keine Sorge, wir werden uns noch näher damit beschäftigen) ein geheimer Schlüssel integriert wird. Die Hashsumme wird dabei in unserem Beispiel über den Ciphertext, d.h. den Verschlüsselten Text, gebildet #footnote[Dies wird als Encrypt-than-Mac bezeichnet.]. Durch den Einbezug eines Schlüssels kann nicht nur überprüft werden, dass die Integrität der Datei nicht verletzt wurde (sie wurde nicht verändert), sondern es kann auch sichergestellt werden, dass die MAC von Ihnen generiert wurde, da nur Sie als Nutzer der Anwendung den geheimen Schlüssel kennen.

```zig
// chapter01/encrypt.zig
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

    // Als erstes parsen wir die übergebenen Kommandozeilenargumente. 
    // Diese bestimmen zum einen mit welchem Passwort die Daten 
    // verschlüsselt werden sollen und zum anderen den Modus, d.h. 
    // ob ver- bzw. entschlüsselt werden soll.
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

        // Der TAG wird von der encrypt() Funktion erzeugt und später 
        // von decrypt() überprüft.
        var tag: [XChaCha20Poly1305.tag_length]u8 = undefined;

        // Für jede Verschlüsselung muss eine neue, einzigartige Nonce 
        // verwendet werden. Da wir die eXtended Version von ChaCha20 
        // verwenden, kann diese durch einen kryptographisch sicheren 
        // Zufallszahlengenerator festgelegt werden.
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

        // Danach können wir die deserialisierten Daten verwenden um 
        // den Ciphertext zu entschlüsseln.
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
```

In diesem Beispiel laufen eine Vielzahl von Konzepten zusammen, die sie im Laufen diese Buches noch häufiger antreffen werden. Unsere Anwendung erwartet Daten, z.B. den Inhalt einer Datei, über `stdin`, sowie zwei Kommandozeilenargumente: `--password` und `--encrypt` bzw. `--decrypt`. Basierend auf diesen Argumenten werden die übergebenen Daten entweder verschlüsselt oder entschlüsselt und nach `stdout` geschrieben.

Wir beginnen mit einigen Top-Level-Deklarationen, damit wir den Pfad zu Datenstrukturen, wie etwa `XChaCha20Poly1305`, nicht immer ausschreiben müssen. Weiterhin definieren wir ein Enum `Mode` welches zwei operationelle Zustände ausdrücken kann, Verschlüsselung (`encrypt`) und Entschlüsselung (`decrypt`).

Innerhalb von `main` parsen wir zuerst die übergebenen Argumente, indem wir durch die Funktion `argsWithAllocator()` einen Iterator über die Kommandozeilenargumente beziehen und mithilfe dessen über die einzelnen Argumente iterieren. Iteratoren sind ein häufig wiederzufindendes Konzept und lassen sich hervorragend mit `while` Schleifen kombinieren. Solange `ai.next()` ein Element zurückliefert, wird diese an `arg` gebunden und die Schleife wird fortgeführt. Liefert `next()` den Wert `null` zurück, so wird automatisch aus der Schleife ausgebrochen.

Danach stellen wir sicher, dass sowohl ein Passwort als auch ein Modus vom Nutzer spezifiziert wurden. Sollte eines der beiden Argumente fehlen, so wird ein entsprechender Fehler gelogged und der Prozess vorzeitig beendet.

Als nächstes wird eine über `stdin` übergebene Datei eingelesen und an die Konstante `data`gebunden. Da der für die Datei benötigte Speicher dynamisch alloziert wird muss dieser wider freigegeben werden. Hierfür wird eine `defer`-Block verwendet, der vor Beendigung der Anwendung ausgeführt wird. Innerhalb dieses Blocks wird zusätzlich der Speicherinhalt mittels `@memset` überschrieben.

#tip-box([
Der Umgang mit Sicherheitsrelevanten Daten ist durchaus herausfordernd. Grundsätzlich muss darauf geachtet werden, dass sensible Daten nicht zu lange im Speicher verweilen. Voraussetzung hierfür ist, dass Sie überhaupt wissen wo überall sensible Daten abgespeichert werden. Zum einen können Sie Daten, nachdem diese nicht mehr benötigt werden, überschreiben. Sie sollten jedoch auch weniger offensichtlich Angriffsvektoren, wie das Swappen von Hauptspeicher, im Hinterkopf behalten.
])

Sowohl für die Ver- als auch Entschlüsselung muss zuerst ein geheimer Schlüssel vom übergebenen Passwort, mittels einer Key-Derivation-Funktion, abgeleitet werden. Für diese Beispiel wird _Argon2id_ #footnote[https://en.wikipedia.org/wiki/Argon2], der Gewinner der 2015 Password Hashing Competition, verwendet. Die Berechnung eines Schlüssels durch Argon2 hängt von den Folgenden (öffentlichen) Parametern ab:

- Salt: eine zufällige Sequenz die in die Schlüsselberechnung einfließt.
- Time: Die Anzahl an Iterationen für die Berechnung.
- Memory: Die Speicher-Kosten für die Berechnung.
- Parallelismus: Die Anzahl an parallelen Berechnungen.

Time, Memory und Parallelismus bestimmen wie aufwändig die Ableitung eines Schlüssels ist. Grundsätzlich gilt: je aufwendiger desto besser, jedoch schlägt sich dies auch in einer längeren Wartezeit nieder (spielen Sie deshalb gerne mit den Parametern). Alle Parameter werden bei der Verschlüsselung festgelegt und müssen mit dem Ciphertext zusammen gespeichert werden, da bei der Entschlüsselung die selben Parameter wieder in die KDF einfließen müssen um den Selben Schlüssel vom Passwort abzuleiten.

Zur Verschlüsselung wird eine zufällige Nonce generiert welche zusammen mit den zu verschlüsselnden Daten, einem Zeiger auf ein Array für den Tag, zusätzliche Daten (in diesem Fall der leere String `""`) und dem abgeleiteten Schlüssel an `encrypt` übergeben werden. Die Funktion verschlüsselt daraufhin die Daten. Danach wird der Salt, die Nonce, der Tag, sowie die verschlüsselten Daten, getrennt durch ein `:`, in die Standardausgabe `stdout` geschrieben.

Für die Entschlüsselung wird dieser String anhand der `:`, mittels `split`, aufgeteilt. Sollten die eingelesenen Daten nicht im erwarteten Format vorliegen, das heißt Salt, Nonce, Tag oder Ciphertext fehlen, so wird ein Fehler ausgegeben und die Anwendung beendet. Andernfalls, werden die eingelesenen Parameter verwendet um den Ciphertext, mittels `decrypt`, wieder zu entschlüsseln.

Das kleine Verschlüsselungsprogramm kann wie folgt verwendet werden:

```bash
$ cat hello.txt 
Hello, World!
$ cat hello.txt | ./encrypt --password=supersecret --encrypt > secret.txt
$ cat secret.txt 
828dfa14efa4b1f8242a8258a411301bd79bc4b7528294500305a4e9baaecbba:
85e4593786697e4e49212131a8e6e6bb68d25f43613dd870:ec666e95ebe1fa4c
53a1183379ae0dbd:80a7fe0475834364229c15dfb96d
$ cat secret.txt | ./encrypt --password=supersecret --decrypt
Hello, World!
```

== Graphische Applikationen

Ein weiterer Anwendungsfall für Zig ist die Entwicklung graphischer Applikationen. Hierfür existiert eine Vielzahl an Bibliotheken, darunter GTK und QT. Was beide Bibliotheken gemeinsam haben ist, dass sie in C beziehungsweise C++ geschrieben sind. Normalerweise würde das die Entwicklung von Bindings voraussetzen, um die Bibliotheken in anderen Sprachen nutzen zu können. Zig integriert jedoch direkt C, wodurch C-Bibliotheken direkt verwendet werden können #footnote[Mit wenigen Einschränkungen. Zig scheitert zurzeit noch an der Übersetzung einer Makros.].

In diesem Abschnitt zeige ich Ihnen, wie sie eine simple GUI-Applikation mit GTK4 und Zig schreiben können. Hierfür müssen Sie zuerst einen neuen Projektordner anlegen.

```bash
$ mkdir gui
$ cd gui
$ zig init
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
info: see `zig build --help` for a menu of options
```

Danach fügen Sie `gtk4` als Bibliothek zu Ihrer Anwendung hinzu. Hierfür öffnen Sie `build.zig` mit einem Texteditor und erweitern die Datei um die folgenden Zeilen:

```zig
// chapter01/gui/build.zig
//...
const exe = b.addExecutable(.{
    //...
});
// Fügen Sie die folgenden beiden Zeilen hinzu
exe.linkLibC();
exe.linkSystemLibrary("gtk4"); 
//...
```

Stellen Sie sicher, dass Sie die Developer-Bibliothek von GTK4 auf Ihrem System installiert haben. Unter Debian/Ubuntu können Sie diese über den APT-Paket-Manager installieren.

```bash
sudo apt install libgtk-4-dev
```

Führen Sie danach *`zig build`* aus um zu überprüfen, dass Zig die benötigte Bibliothek auf Ihrem System findet. Erzeugen Sie als nächstes die Datei _src/gtk.zig_ und fügen Sie den Folgenden Code hinzu:

```zig
// chapter01/gui/src/gtk.zig
pub usingnamespace @cImport({
    @cInclude("gtk/gtk.h");
});

const c = @cImport({
    @cInclude("gtk/gtk.h");
});

/// g_signal_connect re-implementieren
pub fn z_signal_connect(
    instance: c.gpointer,
    detailed_signal: [*c]const c.gchar,
    c_handler: c.GCallback,
    data: c.gpointer,
) c.gulong {
    var zero: u32 = 0;
    const flags: *c.GConnectFlags = @as(*c.GConnectFlags, @ptrCast(&zero));
    return c.g_signal_connect_data(
        instance,
        detailed_signal,
        c_handler,
        data,
        null,
        flags.*,
    );
}
```

Zig ist zwar ziemlich gut darin mit C zu integrieren, jedoch werden Sie von Zeit zu Zeit noch auf Probleme stoßen. In den meisten Fällen lässt sich dies jedoch relativ einfach lösen. 
Innerhalb von `src/gtk.zig` inkludieren wir zuerst die GTK4 Header-Datei `gtk.h`. Wie Ihnen vielleicht aufgefallen ist, haben wir an keiner Stelle innerhalb von `build.zig` auf diese Datei verwiesen. Zig reicht es in den aller meisten Fällen aus, wenn Sie die Bibliothek benennen die Sie einbinden möchten und fügt die benötigten Pfade automatisch hinzu. 

Das Schlüsselwort `usingnamespace` sorgt dafür, dass wir auf alle in `gtk.h` deklarierten Objekte, über `gtk.zig`, direkt zugreifen können. 

Eine in `gtk.h` deklarierte Funktion, die wir später noch benötigen, ist `g_signal_connect`. Diese lässt sich leider nicht ohne weiteres direkt verwenden (einer der seltenen Fälle bei denen Zig derzeit noch versagt). Aus diesem Grund implementieren wir die Funktion selber und nennen unsere Implementierung `z_signal_connect`.

Nun haben wir alles vorbereitet und können uns um die eigentliche Anwendung kümmern. Ersetzen Sie den Code in `src/main.zig` mit dem folgenden Programm:

```zig
// chapter01/gui/src/main.zig
const std = @import("std");
const gtk = @import("gtk.zig");

fn onActivate(app: *gtk.GtkApplication) void {
    const window: *gtk.GtkWidget = gtk.gtk_application_window_new(app);

    gtk.gtk_window_set_title(
        @as(*gtk.GtkWindow, @ptrCast(window)),
        "Zig Basics",
    );
    gtk.gtk_window_set_default_size(
        @as(*gtk.GtkWindow, @ptrCast(window)),
        920,
        640,
    );

    gtk.gtk_window_present(@as(*gtk.GtkWindow, @ptrCast(window)));
}

pub fn main() !void {
    const application = gtk.gtk_application_new(
        "de.zig.basics",
        gtk.G_APPLICATION_FLAGS_NONE,
    );
    _ = gtk.z_signal_connect(
        application,
        "activate",
        @as(gtk.GCallback, @ptrCast(&onActivate)),
        null,
    );
    _ = gtk.g_application_run(
        @as(*gtk.GApplication, @ptrCast(application)),
        0,
        null,
    );
}
```

Ganz oben importieren wir die Standardbibliothek, als auch die Datei `gtk.zig` unter dem Namen `gtk`. Danach folgt die Funktion `onActivate`, welche verwendet wird um ein GTK-Fenster zu erzeugen. Schauen wir uns aber zuerst die `main` Funktion an.

Innerhalb von `main` wird als erstes, mithilfe von `gtk_application_new`,  ein Anwendungsobjekt erzeugt, welches an die Konstante `application` gebunden wird. Als nächstes wird an Callback registriert, der durch das Signal `activate` aufgerufen wird. Als Callback nutzen wir die Funktion `onActivate`. Nachdem die Anwendung mittels `g_application_run` die GTK-Anwendung gestartet hat, wird das `activate` Signal ausgelöst, wodurch `onActivate` aufgerufen wird.

Die Funktion `onActivate` erzeugt als erstes ein neues Fenster für die Anwendung und weist dem Fenster, mithilfe von `get_window_set_title`, den Titel _Zig Basics_ zu. Danach wird eine Fenstergröße von _920 x 640_ Pixeln festgelegt, bevor das Fenster mit `gtk_window_present` angezeigt wird.

Innerhalb des Root-Verzeichnisses des Projekts können Sie mit *`zig build run`* die Anwendung starten. Nach dem Starten des Programms sollten Sie ein leeres Fenster sehen.

#figure(
  image("../images/chapter01/gtk-window.png", width: 60%),
  caption: [
    Leeres GKT4-Fenster
  ],
)

Nur ein leeres Fenster ist etwas langweilig, deshalb fügen wir als nächstes noch einen Button hinzu, der den Text _"Hello, World!"_ auf der Kommandozeile ausgibt. Ich weis, ein Button ist nicht viel spannender als ein leeres Fenster, er sollte jedoch als Beispiel genügen.

Zuerst muss ein Callback definiert werden, der aufgerufen wird sobald der Button vom Nutzer gedrückt wird.

```zig
// chapter01/gui/src/main.zig
fn onButtonClicked(_: *gtk.GtkWidget, _: gtk.gpointer) void {
    std.log.info("Hello, World!", .{});
}
```

Callbacks in GTK erwarten zwei Argumente, einen Zeiger auf das Widget (z.B. der Button) welches den Callback ausgelöst hat und optional einen Zeiger auf Daten, die an die Funktion übergeben werden sollen. Da wir weder das Widget noch Daten benötigen, werden die Parameternamen durch `_` ersetzt. Damit stellen wir den Compiler zufrieden der erwartet, dass alle deklarierten Variablen verwendet werden, Parameter eingeschlossen.

Allgemein setzt sich eine GTK Anwendung aus Widgets (Bausteinen) zusammen. Alles was in einem Fenster angezeigt wird, wird intern als Baumstruktur, bestehend aus Objekten vom Typ `GtkWidget`, abgebildet, wobei das Fenster selber die Wurzel des Baums ist. `GtkWidget` ist dabei ein generischer Typ, das heist er umfasst Verhalten das von allen Bausteinen geteilt wird, egal ob es sich dabei um einen Button, Text oder eine andere graphische Komponente handelt.

Fügen Sie den folgenden Code zwischen dem Aufruf von `gtk_window_set_default_size` und `z_signal_connect` ein.

```zig
// chapter01/gui/src/main.zig
const button = gtk.gtk_button_new_with_label("Click Me!");
gtk.gtk_window_set_child(
    @as(*gtk.GtkWindow, @ptrCast(window)),
    @as(*gtk.GtkWidget, @ptrCast(button)),
);
_ = gtk.z_signal_connect(
    button,
    "clicked",
    @as(gtk.GCallback, @ptrCast(&onButtonClicked)),
    null,
);
```

Da alle Bausteine als `GtkWidget` verwendet werden können ist es teilweise nötig einzelne Zeiger auf den richtigen, von einer Funktion erwarteten, Parametertypen zu casten. Der Ausdruck `@as(*gtk.GtkWindow, @ptrCast(window))` bedeutet zum Beispiel: betrachte den Zeiger `window` als einen Zeiger zu einem `GtkWindow`.

Mit der Funktion `gtk_window_set_child` kann ein Widget als Kind des gegebenen Fensters gesetzt werden. Danach registrieren wir noch einen Callback für den Button, der bei einem Click (Signal _"clicked"_) ausgelöst wird. Als Callback verwenden wir die Funktion `onButtonClicked`, die wir zuvor definiert hatten.

Nachdem Sie das Programm mit *`zig build run`* gestartet haben sollten Sie innerhalb des Fensters einen Button sehen, der das Fenster ausfüllt. 

#figure(
  image("../images/chapter01/gtk-window-button.png", width: 60%),
  caption: [
    GKT4-Fenster mit Button
  ],
)

Beim clicken des Buttons sollte _"Hello, World!"_ auf der Kommandozeile ausgegeben werden.  
Herzlichen Glückwunsch! Sie haben ihre erste graphische Benutzerobefläche in Zig programmiert.

== Zig als C Build-System

