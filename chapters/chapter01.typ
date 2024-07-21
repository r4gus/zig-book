#import "../tip-box.typ": tip-box

= Zig Crash Course

In diesem Kapitel schauen wir uns einige kleine Zig Programme an, damit Sie ein Gespür für die Programmiersprache bekommen. Machen Sie sich nicht zu viele Sorgen wenn Sie nicht alles sofort verstehen, in den folgenden Kapiteln werden wir uns mit den hier vorkommenden Konzept noch näher beschäftigen. Wichtig ist, dass Sie diese Kapitel nicht nur lesen sondern die Beispiel auch ausführen, um das meiste aus diesem Kapitel herauszuholen.

== Zig installieren

Um Zig zu installieren besuchen Sie die Seite #link("https://ziglang.org") und folgen den Instruktionen unter "GET STARTED" #footnote[https://ziglang.org/learn/getting-started/].

Die Installation ist unter allen Betriebssystemen relativ einfach durchzuführen. In der Download Sektion #footnote[https://ziglang.org/download/] finden Sie vorkompilierte Zig-Compiler für die gängigsten Betriebssysteme, darunter Linux, macOS und Windows, sowie Architekturen. 

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
- *zig*: Dies ist der Compiler, den wir im Laufe dieses Buchs exzessiv verwenden werden.

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

Unsere `main` Funktion beginnt, wie alle Funktionen, mit `fn` und dem Namen der Funktion. Sie gibt keinen Wert zurück, aus diesem Grund folgt auf die leere Parameterliste `()` der Rückgabetyp `void`. Das Ausrufezeichen `!` weist darauf hin, das die Funktion einen Fehler zurückgeben kann.

```zig
std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
```

Als erstes gibt die `main` Funktion einen String über die Debugausgabe auf der Kommandozeile aus. Die Funktion `print` erwartet dabei einen Format-String, der mit Platzhaltern (z.B. `{s}`) angereichert werden kann, sowie eine Liste an Ausdrücken (z.B. `.{"codebase"}`) deren Werte in den String eingefügt werden sollen. Der Platzhalter `{s}` gibt z.B. an, dass an der gegebenen Stelle ein String eingefügt werden soll. Neben `s` gibt es unter anderem noch `d` für Ganzzahlen und `any` für beliebige werte. 

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

Zig unterscheidet zwischen zwei Variablen-Typen, Variablen und Konstanten. Konstanten können nach ihrer Initialisierung nicht mehr verändert werden, während Variablen neu zugewiesen werden können. Funktionsargumente zählen grundsätzlich zu Konstanten, d.h. sie können nicht verändert werden. Der Zig-Compiler erzwingt die Nutzung von Konstanten, sollte eine Variable nach ihrer Initialisierung nicht mehr verändert werden. Dies ist eine durchaus kontroverse Designentscheidung, kann aber auf das Zig-Zen zurückgeführt werden das besagt: ,,Favor reading code over writing code". Sollten Sie also eine Variable in fremden Code sehen so können Sie sicher sein, dass diese an einer anderen Stelle manipuliert bzw. neu zugewiesen wird.

Eine Besonderheit, die Zig von anderen Sprachen unterscheidet ist, dass Integer mit beliebiger Präzision unterstützt werden. Im obigen Beispiel handelt es sich bei `u64` um eine vorzeichenlose Ganzzahl (unsigned integer) mit 64 Bits, d.h. es können alle Zahlen zwischen 0 und $2^64 - 1$ dargestellt werden. Zig unterstützt jedoch nicht nur `u8`, `u16`, `u32` oder `u128` sondern alle unsigned Typen zwischen `u0` und `u65535`.

#tip-box([
Alle Zig-Basistypen sind Teil des selben `union`: std.builtin.Type. Das union beinhaltet den `Int` Typ welcher ein `struct` mit zwei Feldern ist, `signedness` und `bits`, wobei `bits` vom Typ `u16` ist, d.h. es können alle Integer-Typen zwischen 0 und $2^16 - 1$ Bits verwendet werden. Ja Sie hören richtig, der Zig-Compiler ist seit Version 0.10.0 selbst in Zig geschrieben, d.h. er ist self-hosted.
])



Innerhalb des Funktonskörpers werden mittels `if` verschiedene Bedingungen abgefragt. Sollte eine beider Zahlen 0 sein, so wird die andere zurückgegeben, ansonsten wird `gcd` rekursiv aufgerufen bis eine beider Zahlen 0 ist. Wie auch bei C muss die Bedingung in runde Klammern gefasst werden. Bei Einzeilern können die geschweiften Klammern um einen Bedingungsblock weggelassen werden. In diesem Fall wird der Inhalt des Bedingungsblocks an den umschließenden Block gereicht.

Mittels eines `return` Statements kann von einer Funktion in die aufrufende Funktion zurückgekehrt werden. Das Statement nimmt bei bedarf zusätzlich einen Wert der an die aufrufende Funktion zurückgegeben werden soll. Im obigen Beispiel gibt `gcd` mittels `return` den Wert des ausgeführten Bedingungsblocks zurück.

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

Innerhalb einer Datei sind Definitionen auf oberster Ebene (top-level definitions) unabhängig von ihrer Reihenfolge, was die Definition von Tests mit einschließt. Damit können Tests an einer beliebigen Stelle definiert werden, darunter direkt neben der zu testenden Funktion oder am Ende einer Datei. Der Zig-Test-Runner sammelt automatisch alle definierten Tests und führt dies beim Aufruf von *`zig test`* aus. Worauf Sie jedoch achten müssen ist, dass Sie ausgehend von der Wurzel-Datei, die konzeptionell den Eintritspunkt für den Compiler in ihr Programm oder Ihre Bibliothek darstellt, Zig mitteilen müssen in welchen Dateien zusätzlich nach Tests gesucht werden soll. Dies bewerkstelligen Sie, indem Sie die entsprechende Datei innerhalb eines Tests importieren.

```zig
const foo = @import("foo.zig");

test "main tests" {
    _ = foo; // Tell test runner to also look in foo for tests
}
``` 

== Comptime

Die meisten Sprachen erlauben eine Form von Metaprogrammierung, d.h. das Schreiben von Code der wiederum Code generiert. In C können die gefürchteten Makros mit dem Präprozessor verwendet werden und Rust bietet sogar zwei verschiedene Typen von Makros, jeweils mit einer eigenen Syntax. Zig bietet mit `comptime` seine eigene Form der Metaprogrammierung. Was Zig von anderen kompilierten Sprachen unterscheidet ist, dass die Metaprogrammierung in der Sprache selber erfolgt, d.h., wer Zig programmieren kann, der hat alles nötige Handwerkszeug um auch Metaprogrammierung in Zig zu betreiben.

Ein Aufgabe für die Metaprogrammierung sehr gut geeignet ist, ist die Implementierung von Container-Typen wie etwa `std.ArrayList`. Eine `ArrayList` ist ein Liste von Elementen eines beliebigen Typen, die eine Menge an Standardfunktionen bereitstellt um die Liste zu manipulieren. Nun wäre es sehr aufwändig die `ArrayList` für jeden Typen einzeln implementieren zu müssen. Aus diesem Grund ist `ArrayList` als Funktion implementiert, welche zur Compilezeit einen beliebigen Typen übergeben bekommt auf Basis dessen ein eigener `ArrayList`-Typ generiert wird. 

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

Mit dem `comptime` Keyword sagen wir dem Compiler, dass das Argument `T` zur Compilezeit erwartet wird. Beim Aufruf von `MyArrayList(u8)` wertet der Compiler die Funktion aus und generiert dabei einen neuen Typen. Das praktische ist, dass wir die eigentliche Funktionalität der unserer ArrayList nur einmal implementieren müssen.

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

== Kommandozeilenargumente

== Parallelität

== C/C++ Build System

Wie wir anfangs gesehen haben bietet `zig` nicht nur einen Compiler, sondern ein vollständiges Build-System. Die Beschreibung, wie ein Projekt gebaut werden soll, erfolgt dabei direkt in Zig und nicht in einer eigenen Sprache wie Sie es vielleicht von Make oder CMake gewohnt sind. Das besondere ist, dass `zig` nicht nur eine Build-System für die Sprache Zig bereitstellt, sondern auch als Build-System für C und C++ Projekte verwendet werden kann und damit u.a. eine Alternative zu Make und CMake darstellt. Dies unterstreicht die enge Beziehung zwischen Zig und C bzw. C++.

Um zu demonstrieren wie Sie Zig als Build-System für ein C Projekt verwenden können, werden wir für _https\:\/\/github.com/libusb/hidapi_ #footnote[https://github.com/libusb/hidapi] ein kleines, unvollständiges Build-Skript schreiben und im Anschluss für eine kleine Beispielanwendung verwenden. Zuerst müssen wir mittels *`git clone https://github.com/libusb/hidapi.git`* das Projekt beziehen. Danach wechseln wir in den Ordner _hidapi_ und erstellen eine neue Datei mit dem Namen _build.zig_.

```bash
git clone https://github.com/libusb/hidapi.git
cd hidapi
touch build.zig
```

=== Bibliothek

Wird von einem C bzw. C++ Projekt bereits ein Build-System verwendet, so lohnt es sich die zugehörigen Dateien zu analysieren um ein Verständniss davon zu bekommen, wie das Projekt derzeit gebaut wird. Im gegebenen Fall ist dies CMake, d.h., wir schauen uns zuerst die Datei _CMakeLists.txt_ an. Ein Großteil des Inhalts der Datei ist für unsere Absichten erst einaml irrelevent und hat größtenteils mit der Konfiguration des Projekts zu tun. Zu diesem Zeitpunkt möchten wir hidapi jedoch lediglich für Linux, ohne besondere Optionen, compilieren. Aus diesem Grund schauen wir nach weiteren Unterordnern, die von _CMakeLists.txt_ eingebunden werden. Einer davon ist _src_.

```CMake
add_subdirectory(src)
```

Zwei Dinge die wir von _src/CMakeLists.txt_ entnehmen können ist, dass das Projekt genau eine Header-Datei enthält (_hidapi/hidapi.h_) und dass für jedes Target (Linux, BSD, macOS und Windows) ein eigener Unterordner existiert. Die Datei _linux/CMakeLists.txt_ wird uns für diese Beispiel als Vorlage dienen.

```CMake
cmake_minimum_required(VERSION 3.6.3...3.25 FATAL_ERROR)

add_library(hidapi_hidraw
    ${HIDAPI_PUBLIC_HEADERS}
    hid.c
)
target_link_libraries(hidapi_hidraw PUBLIC hidapi_include)

find_package(Threads REQUIRED)

include(FindPkgConfig)
pkg_check_modules(libudev REQUIRED IMPORTED_TARGET libudev)

target_link_libraries(hidapi_hidraw PRIVATE PkgConfig::libudev Threads::Threads)

set_target_properties(hidapi_hidraw
    PROPERTIES
        EXPORT_NAME "hidraw"
        OUTPUT_NAME "hidapi-hidraw"
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
        PUBLIC_HEADER "${HIDAPI_PUBLIC_HEADERS}"
)

# compatibility with find_package()
add_library(hidapi::hidraw ALIAS hidapi_hidraw)
# compatibility with raw library link
add_library(hidapi-hidraw ALIAS hidapi_hidraw)

if(HIDAPI_INSTALL_TARGETS)
    install(TARGETS hidapi_hidraw EXPORT hidapi
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/hidapi"
    )
endif()

hidapi_configure_pc("${PROJECT_ROOT}/pc/hidapi-hidraw.pc.in")
```

Als erstes definieren wir eine neue Bibliothek und geben dieser einen Namen, sowie Informationen über das Target (z.B. X86\_64 Linux) sowie Informationen zu gewünschten Optimierungen. Außerdem definieren wir eine Option, um Anwendern die Möglichkeit zu geben zwischen einer statischen oder dynamsichen Bibliothek zu wählen. Als Default wählen wir dabei `true`, d.h. standardmäßig wird eine statische Bibliothek gebaut.

```zig
// hidapi/build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const static = b.option(bool, "static", "Make a static library") orelse true;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = if (static) blk: {
        break :blk b.addStaticLibrary(.{
            .name = "hidapi",
            .target = target,
            .optimize = optimize,
        });
    } else blk: {
        break :blk b.addSharedLibrary(.{
            .name = "hidapi",
            .target = target,
            .optimize = optimize,
        });
    };

    b.installArtifact(lib);
}
```

Nachdem Sie den obigen Code zu _build.zig_ hinzugefügt haben können Sie mittels *`build zig --help`* sich einen Hilfetext ausgeben lassen, der u.a. unsere Option beinhalten sollte.

```bash
$ build zig --help
Usage: /usr/local/bin/zig-linux-x86_64-0.13.0/zig build [steps] [options]
...
Project-Specific Options:
  -Dstatic=[bool]              Make a static library
```

Zwar können wir uns einen Hilfetext anzeigen lassen, jedoch schlägt das Compilieren beim Ausführen von *`build zig`* fehl. Was fehlt ist Quellcode, aus der die Bibliothek gebaut werden soll. Um es einfach zu halten unterstützen wir in diesem Beispiel nur Linux, es steht Ihnen jedoch Frei auch Unterstützung für andere Betriebssysteme hinzuzufügen. Über die `target` Variable können wir u.a. das Betriebssystem, für welches die Bibliothek gebaut werden soll, bestimmen.

#tip-box([
    Zig unterstützt Cross-Compilation, d.h. Architektur und Betriebssystem auf dem eine Anwendung oder Bibliothek compiliert wird kann sich von der Architektur bzw. dem Betriebssystem unterscheiden, für welches Compiliert wird. Die Variable `target` enthält Informationen über das Zielsystem.
])

Für unser Beispiel machen wir eine einfache Fallunterscheidung. Sollte das Zielsystem `.linux` sein, so fügen wir die benötigten _.c_ Dateien zu `lib` hinzu und linken zusätzlich die benötigte Bibliothek `libudev`. Andernfalls kehren wir einfach frühzeitig von der `build` Funktion zurück.

```zig
// hidapi/build.zig
// ...

if (target.result.os.tag == .linux) {
    lib.addCSourceFiles(.{
        .files = &.{"linux/hid.c"},
        .flags = &.{"-std=gnu11"},
    });

    // Manche Linux-Distros (z.B. OpenSuse) besitzen keine Developer-Package
    // von libudev, d.h. es fehlt die Datei `libudev.h`. In diesem Fall kann
    // die Datei manuell bezogen
    //    https://github.com/mcatalancid/libudev/blob/1.8.2/src/libudev.h
    // und in das Projekt integriert werden. In diesem Fall einfach die
    // folgende Zeile einfügen:
    // lib.addSystemIncludePath(b.path("./"));

    // Abhängig von der Linux-Distor muss `udev` evtl. durch `libudev` ersetzt werden.
    lib.linkSystemLibrary("udev");
} else {
    // An dieser Stelle wäre eine bessere Fehlerkommunikation angebracht.
    return;
}

// Der Unterordner ./hidapi enthält die `hidapi.h` Header-Datei
lib.addIncludePath(b.path("hidapi"));
lib.linkLibC();

// ...

b.installArtifact(lib);

```

Beim linken von Bibliotheken mittels `linkSystemLibrary` sucht Zig nach den Bibliotheken in den gängigsten Ordnern, darunter _/usr/lib_. Außerdem werden die zugehörigen Header automatisch dem Include-Pfad hinzugefügt. Oft wird jedoch das Developer-Paket einer Bibliothek benötigt um auch an die Header-Dateien auf seinem System zu gelangen. Im Fall von `libudev` ist ein solches Developer-Paket jedoch nicht unter allen gängigen Linux Distributionen vorhanden, z.B. gibt es unter Ubuntu _libudev-dev_, jedoch nicht unter OpenSuse #footnote[Die Beschaffung benötigter Bibliotheken ist in der Regel "Out-of-Scope", d.h. es ist die Aufgabe des Nutzers die benötigten Bibliotheken auf seinem System zu installieren. Für das gegebene Beispiel habe ich trotzdem ein Kommentar diesbezüglich eingefügt, mit einem Link zur benötigten Header-Datei.].

Da unsere _hidapi_ Bibliothek selber auch _hidapi.h_ zum compilieren benötigt, geben wir dessen relativen Pfad mittels der Funktion `addIncludePath()` an. Außerdem müssen wir bei C bzw. C++ Projekten in den meisten Fällen, mittels `linkLibC()`, die C-Standard-Bibliothek verlinken.

Damit ist unser Build-Script vollständig und wir können mit *`build zig`* unsere Bibliothek (unter Linux bzw. für Linux) bauen. Nach dem Compilieren findet sich diese unter _zig-out/lib_ im Root-Verzeichnis von _hidapi_.

Um die _hidapi_ Bibliothek, welche durch _build.zig_ beschrieben wird, in anderen Zig Projekten einfach verwenden zu können, müssen wir noch zwei Dinge hinzufügen. Zum einen sollten wir die für _hidapi_ benötigten Header (_hidapi/hidapi.h_) exportieren.

```zig
// hidapi/build.zig
// ...
lib.installHeader(b.path("hidapi/hidapi.h"), "hidapi.h");
// ...
```

Damit wird beim Linken von _hidapi_ durch ein anderes Zig-Projekt, diesem auch gleichzeitig der Pfad zur Header-Datei mitgeteilt.

Zum anderen wird eine _build.zig.zon_ Datei benötigt, die weitere Informationen zum _hidapi_ Projekt bereitstellt.

```zon
// hidapi/zig.build.zon
.{
    .name = "hidapi",
    .version = "0.1.0",
    .dependencies = .{},
    .paths = .{
        "build.zig",
        "build.zig.zon",
        ".builds",
        "android/jni",
        "dist",
        "documentation",
        "doxygen",
        "hidapi",
        "hidtest",
        "libusb",
        "linux",
        "m4",
        "mac",
        "pc",
        "src",
        "subprojects",
        "testgui",
        "udev",
        "windows",
        ".appveyor.yml",
        ".cirrus.yml",
        ".gitattributes",
        ".gitignore",
        "AUTHORS.txt",
        "HACKING.txt",
        "LICENSE.txt",
        "README.md",
        "VERSION",
        "bootstrap",
        "configure.ac",
        "meson.build",
    },  
} 
```

Die meisten Felder sind dabei selbsterklärend. Das Feld `.paths` gibt an welche Dateien zum gegebenen Projekt gehören, woraus sich u.a. der Paket-Hash berechnet.

=== Verwendung der Bibliothek
