#import "../tip-box.typ": tip-box

= Speicherverwaltung

Im Vergleich zu anderen Sprachen, wie etwa Java oder Python, muss der Speicher in Zig manuell verwaltet werden. Dies bringt einige Vorteile mit sich, birgt aber auch Risiken, die bei Nichtbeachtung zu Schwachstellen in den eigenen Anwendungen führen können. Was Zig von anderen Sprachen mit manueller Speicherverwaltung hervorhebt ist die explizite Verwendung und Verwaltung von Allokatoren, in der Programmiersprache repräsentiert durch den `Allocator` Typ. Dies kann von anderen Programmiersprachen kommenden Entwicklern anfangs ungewohnt vorkommen, bietet jedoch ein hohes Maß an Flexibilität, da Speicher zur Laufzeit dynamisch von verschiedenen Speicherquellen alloziert werden kann.

== Grundlagen

In den meisten Fällen kann ein Programm von zwei verschiedenen Quellen Speicher allozieren, dem Stack und dem Heap. Wird eine Funktion aufgerufen, so alloziert diese Speicher auf dem Stack der von den lokalen Variablen und Parametern zur Speicherung der zugehörigen Werte verwendet wird. Dieser, von einer Funktion allozierte, Speicherbereich wird als Stack-Frame bezeichnet. Die Allokation eines Stack-Frames wird durchgeführt, indem der Wert eines spezielles CPU-Register, der sog. Stack-Pointer welcher auf das Ende des Stacks zeigt, verringert wird. Die Anzahl an Bytes um die der Stack-Pointer verringert werden muss um alle lokalen Variablen halten zu können wird vom Compiler zur Compilezeit berechnet und in entsprechende Assemblerinstruktionen übersetzt.

Durch die Einschränkung, dass die Größe eines Stack-Frames zur Compilezeit bekannt sein muss, lassen sich bestimmte Aufgaben schwer lösen. Angenommen Sie wollen eine Zeichenkette unbekannter Länge von Ihrem Programm einlesen lassen, um diese später zu verarbeiteten. Eine Möglichkeit um die Zeichenkette zu speichern wäre innerhalb der `main` Funktion eine Variable vom Typ Array mit fester Länge zu deklarieren, jedoch ist dieser Ansatz sehr unflexibel da Sie in dem gegebenen Szenario die Länge der zu erwartenden Zeichenkette nicht kennen. Bei besonders kurzen Zeichenketten verschwenden Sie ggf. Speicher während sich besonders lange Zeichenketten nicht einlesen lassen, da nicht genügend Speicher auf dem Stack alloziert wurde. Um Probleme solcher Art besser lösen zu können, kann Speicher dynamisch zur Laufzeit eines Programms alloziert werden. Der Heap kann als linearer Speicherbereich betrachtet werden, der von einem Allokator verwaltet wird. Wird Speicher zur Laufzeit benötigt, so kann der Allokator durch einen Funktionsaufruf angewiesen werden eine bestimmte Menge an Bytes zu allozieren. Der Allokator sucht ein Stück Speicher mit der passenden Länge heraus, markiert dieses als alloziert und gibt einen Zeiger auf den Beginn des Speicherbereichs zurück. Wird der Speicher nicht mehr benötigt, so kann der Allokator durch einen weiteren Funktionsaufruf aufgefordert werden den Speicher wieder frei zu geben. In C und C++ verwenden Sie i.d.R. `malloc` und `free` um Speicher zu allozieren bzw. freizugeben, in den wenigsten Fällen müssen Sie sich jedoch Gedanken um den zu verwendenden Allokator machen. Im Gegensatz dazu verwenden Sie in Zig immer explizit einen Allokator.

In vielen Fällen, vor allem als Neuling, ist die Unterscheidung zwischen den vielen verschiedenen Arten von Allokatoren, welche die Zig Standartbibliothek bereitstellt, weniger interessant. Wird ein Standard-Allokator, im Sinne von `malloc` und `free`, benötigt, so kann auf den GeneralPurposeAllocator zurückgegriffen werden.

```zig
const Gpa = std.heap.GeneralPurposeAllocator(.{});
var gpa = Gpa{};                                      
const allocator = gpa.allocator();
```

Die Funktion `GeneralPurposeAllocator` erwartet ein Konfigurationsstruct als Argument zur Compilezeit und gibt einen neuen `GeneralPurposeAllocator`-Typ zurück der der Konstante `Gpa` zugewiesen wird. In den meisten Fällen kann durch Verwendung von `.{}` als Argument die Standardkonfiguration übernommen werden. Danach kann der `Gpa` Allokator-Typ verwendet werden um ein neues Allokator-Object zu erzeugen und an die Variable `gpa` zu binden. Durch Aufruf der `allocator()` Funktion auf dem Objekt kann schlussendlich auf den eigentlichen Allokator zugegriffen werden. Dies mag auf den ersten Blick kompliziert wirken, vor allem im Vergleich zu anderen Sprachen wo Funktionen wie `malloc()` scheinbar immer zur Verfügung stehen, in den meisten Fällen reicht es aber aus, den Allokator einmal am Anfang der Anwendung zu instanziieren. Danach kann dieser zur Allokation von Speicher verwendet werden. Der Allocator-Typ erlaubt es verschiedene Allokatoren durch das selbe, standardisierte Interface zu verwenden. Das bedeutet, dass Entwickler von Bibliotheken bzw. Modulen das gesamte dynamische Speichermanagement durch einen Typen (Allocator) handhaben können, während die Verwender von besagten Bibliotheken die freie Wahl bezüglich des dahinter liegenden Allokators besitzen.

Beim Allozieren von Speicher wird in Zig grundsätzlich zwischen der Allokation von exakt einem Objekt und der Allokation mehrerer Objekte unterschieden. Soll speicher für genau ein Objekt alloziert werden, so muss `create()` zum allozieren und `destroy()` zum Freigeben des Speichers verwendet werden. Andernfalls können die Funktionen `alloc()` und `free()` verwendet werden. Die Funktion `create()` erwartet einen Typen (`type`) als Argument und alloziert daraufhin Speicher für exakt eine Instanz dieses Typen. Eine Allokation kann jedoch fehlschlagen, z.B. weil kein ausreichender Speicher auf dem Heap vorhanden ist. Aus diesem Grund gibt `create()` nicht direkt einen Zeiger auf den allozierten Speicher zurück, sondern einen Fehler-Typ. Damit werden Entwickler gezwungen sich bewusst zu machen, dass eine Allokation fehlschlagen kann. Dies spiegelt sich auch im Zig-Zen wieder, in welchem es u.a. heißt: ,,Resource allocation may fail; resource deallocation must succeed'' (auf Deutsch: Die Allokation von Resourcen kann fehlschlagen; die deallokation von Resourcen muss gelingen).

```zig
// chapter03/hello_world.zig
const std = @import("std");

const Gpa = std.heap.GeneralPurposeAllocator(.{});
var gpa = Gpa{};
const allocator = gpa.allocator();

pub fn main() !void {
    const T = u8;
    const L = "Hello, World".len;
    
    // Hier allozieren wir Speicher für L Elemente vom Typ `u8` .
    const hello_world = allocator.alloc(T, L) catch {
        // Im Fall, dass der Speicher nicht alloziert werden kann,
        // geben wir eine Fehlermeldung aus und beenden den
        // Prozess ordnungsgemäß.
        std.log.err("We ran out of memory!", .{});
        return;
    };
    // Defer wird vor dem Verlassen der Funktion ausgeführt.
    // Es ist 'good practice' Speicher mittels `defer` zu
    // deallozieren.
    defer allocator.free(hello_world);
    
    // Wir kopieren "Hello, World" in den allozierten Speicher.
    @memcpy(hello_world, "Hello, World");
    
    // Nun geben wir den String auf der Kommandozeile aus.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("{s}\n", .{hello_world});
    try bw.flush();
}
```

Das obige Programm gibt ,,Hello, World'' auf der Kommandozeile aus, jedoch allozieren wir vor der Ausgabe, zur Veranschaulichung, Speicher für den auszugebenden String auf dem Heap. Die Funktion `alloc()` erwartet als Argument den Typ, für den Speicher alloziert werden soll (`u8`), sowie die Anzahl an Elementen. Aus dem Typ `T` und der Anzahl `L` berechnet sich die Anzahl an Bytes die benötigt werden um `L` mal den Typ `T` im Speicher zu halten (`@sizeOf(T) * L`). Wie bereits erwähnt kann die Speicherallokation fehlschlagen, aus diesem Grund müssen wir denn Fehlerfall berücksichtigen bevor wir auf den Rückgabewert von `alloc()` zugreifen können #footnote[Anstelle eines catch Blocks hätten wir an dieser Stelle auch try verwenden können.]. Da `alloc()` Speicher für mehr als ein Objekt alloziert, gibt die Funktion anstelle eines Zeigers auf den Typ `T` einen Slice vom Typ `T` zurück. Ein Slice ist ein Wrapper um einen Zeiger, der zusätzlich die Länge des referenzierten Speicherbereichs kodiert. Nach außer verhält sich ein Slice wie ein Zeiger in C, d.h. mit dem Square-Bracket-Operator `[]` kann auf einzelne Element zugegriffen werden, jedoch wird vor jedem Zugriff überprüft, ob der angegebene Index innerhalb des allozierten Bereichs liegt um Out-of-Bounds-Reads zu vorzubeugen. Slices ersetzen in vielen Fällen null-terminierte Strings, was dabei hilft Speicherfehlern vorzubeugen.

Ein wichtiger Punkt der zu jeder Allokation gehört ist die Deallokation des allozierten Speichers. In Zig kann diese direkt nach dem Aufruf von `alloc()` bzw. `create()` platziert werden, indem dem Aufruf von `free()` der defer Operator vorangestellt wird. Defer sorgt dafür, dass vor dem Verlassen eines Blocks, im obigen Beispiel ist dies der Funktionsblock von main, alle defer Blöcke ausgeführt werden und zwar in umgekehrter Reihenfolge in der sie deklariert werden. Dies ist vor allem zum Aufräumen von Ressourcen sehr hilfreich.

#tip-box([
    Sehen Sie beim Lesen von Zig-Code keinen `defer` Block zur Bereinigung von Speicher direkt nach einer Allokation sollten Sie erst einem stutzig werden. Es gibt aber auch Situationen, z.B. bei der Verwendung eines ArenaAllocators, in denen nicht jede einzelne Allokation manuell bereinigt werden muss. In solchen Fällen ist es aber durchaus nützlich für Leser Ihres Quellcodes, wenn Sie durch ein Kommentar ersichtlich machen, dass das Fehlen einer Deallokation beabsichtigt ist.
])

== Lifetimes

Bei der Verwendung von Programmiersprachen mit manuellem Speichermanagement ist die Berücksichtigung der Lifetime (Lebenszeit) von Objekten essenziell um Speicherfehler zu vermeiden. Die Lifetime eines Objekts beschreibt ein abstraktes Zeitintervall zur Laufzeit, in welchem ein bestimmtes Objekt oder eine Sequenz von Objekten im Speicher existieren und auf diese zugegriffen werden darf. Die Art wie bzw. wo Speicher für ein Objekt alloziert wird hat dabei großen Einfluss auf dessen Lebenszeit. Im Allgemeinen beginnt die Lifetime eines Objekts mit dessen Erzeugung und endet wenn der Speicher des Objekt wieder freigegeben wird. Bezogen auf die Art der Allokation kann grob zwischen den folgenden Fällen unterschieden werden:

- Statische Allokation
- Automatische Allokation
- Dynamische Allokation

=== Static Memory

In Zig, wie auch in C, befinden sich statische Variablen und Konstanten, die im globalen Scope, bzw. im Fall von Zig in einem Container #footnote[Ein Container in Zig ist jedes Konstrukt, das als Namensraum (engl. namespace) dient. Dazu zählen u.a. Structs aber auch Sourcedateien.], einer Anwendung deklariert werden, in der .data oder .bss Section eines Programms. Speicher für diese Sektionen wird beim Start eines Prozesses gemapped und er bleibt bis zur Terminierung des Prozesses valide. Variablen die dies betrifft haben eine statische Lifetime, d.h. sie sind vom Start eines Prozesses bis zu dessen Beendigung valide. Selbes gilt für statische, lokale Variablen.

```zig
const std = @import("std");

const hello = "Hello, World";

pub fn main() void {
    const local_context = struct {
        var x: u8 = 128;
    };

    std.log.info("{s}, {d}", .{ hello, local_context.x });
}
```

Die Konstante `hello` wird im umschließenden Container, dargestellt durch die Quelldatei, deklariert und ist damit zum einen statisch, zum anderen ist sie aufgrund des `const` Modifiers zur Compilezeit bekannt. Selbes gilt für die lokale, statische Variable `x`. Im gegensatz zu C werden statische, lokalen Variablen nicht mit dem static Keyword deklariert sondern innerhalb eines lokalen Structs welches ebenfalls einen Container darstellt. Lokale, statische Variablen können nützlich sein um z.B. einen gemeinsamen "Shared-State" zwischen Aufrufen der selben Funktion zu verwirklichen.

#tip-box([
    In Zig wird jede Translationunit, d.h. jede Datei in der Quellcode liegt, als Struct und damit als Container betrachtet. Dementsprechend gibt es eigentlich keine global deklarierten Variablen wie man sie aus C kennt, sondern nur statische Variablen die in Containern deklariert werden.
])

=== Automatic Memory

Objekte die durch Deklaration bzw. Definition innerhalb eines (Funktions-)Blocks erzeugt werden erben ihre Lifetime von dem umschließenden Block. Für Variablen und Parameter von Funktionen bedeutet dies, dass sich ihre Lifetime an der Lifetime eines Stack-Frames orientiert. Bei jedem Funktionsaufruf wird für den Aufruf ein Stück zusammenhängender Speicher auf dem Stack alloziert (der Stack-Frame) welcher groß genug ist um alle lokalen Variablen und Parameter zu halten. Der Frame wird dabei durch zwei Spezialregister der CPU, dem Stack-Pointer (SP) und dem Base-Pointer (BP), eingegrenzt. Der Stack-Pointer zeigt dabei auf das Ende vom Stack.

#tip-box([
    Es gibt verschiedene Arten von Stacks, jedoch ist die wohl häufigst auftretende Form der Full-Descending-Stack. Das bedeutet, dass der Stack nach unten "wächst" (Descending), d.h. von höheren zu niedrigeren Speicheradressen, und der Stack-Pointer auf das erste valide Element des Stacks zeigt (Full).
])

```zig
// chapter03/stack_01.zig
const std = @import("std");

pub fn main() !void {
    var i: usize = 0; // Begin der Lifetime von 'i' --/
                      //                              /
    try foo(&i); // foo referenziert 'i'              /
} // Ende der Lifetime von 'i' -----------------------/

pub fn foo(a: *u64) !void { // Begin der Lifetime von 'a' --/
    a.* += 1;               //                              /
} // Ende der Lifetime von 'a' -----------------------------/
```

Das obige Programm übergibt eine Referenz auf die Variable `i` als Argument an die Funktion `foo()`, welche `i` inkrementiert. Die Lifetime der Variable startet mit ihrer Definition und endet mit dem Funktionsblock von main. Innerhalb der Lifetime darf `i` von anderen Programmteilen, in diesem Fall der Funktion `foo()`, referenziert und ggf. modifiziert werden.

Die Lifetime der Referenz `a` zu `i` beginnt mit dem Funktionsblock von `foo()` und endet mit dem Ende des Funktionsblocks. Wichtig ist, dass die Lifetime einer Referenz immer innerhalb der Lifetime des referenzierten Objekts liegen muss. Überschreitet die Lifetime einer Referenz die Lifetime des referenzierten Objekts so spricht man von einem dangling Pointer (auf Deutsch hängender Zeiger). Die Verwendung solcher dangling Pointer können zu schwerwiegenden Programmfehlern führen, da der referenzierte Speicher als undefiniert gilt.

Um das Verhalten der Anwendung besser nachvollziehen zu können, besteht die Möglichkeit mithilfe des Programms objdump die kompilierte Anwendung zu disassemblieren: *`objdump -d -M intel stack_01`*. Der Eintrittspunkt einer jeden Anwendung ist dabei die `main` Funktion.

```asm
00000000010349b0 <stack_01.main>:
 10349b0: push   rbp        ; Begin Prolog ---|
 10349b1: mov    rbp,rsp    ;                 |
 10349b4: sub    rsp,0x10   ; End Prolog -----|
 10349b8: mov    QWORD PTR [rbp-0x8],0x0 ; i = 0
 10349bf:       00 
 10349c0: lea    rdi,[rbp-0x8]           ; &i
 10349c4: call   10348e0 <stack_01.foo>
 10349cb: add    rsp,0x10   ; Begin Epilog --|
 10349cf: pop    rbp        ; End Epilog ----|
 10349d0: ret
```

Jede Funktion besitzt ein Symbol (im Fall von main ist dies `stack_01.main`) welches repräsentativ für die Adresse der ersten Instruktion steht. Beim Funktionsaufruf wird diese Adresse in das Instruktions-Zeiger-Register (Instruction Pointer - IP) geschrieben, welcher immer auf die nächste auszuführende Instruktion zeigt. Jede Funktion beginnt mit dem sogenannten Funktions-Prolog, welcher einen neuen Stack-Frame für den Funktionsaufruf erzeugt, und endet mit dem Funktions-Epilog, welcher den Stack-Frame wieder entfernt, d.h. den Stack in den Zustand vor dem Funktionsaufruf zurückversetzt.

Im Prolog wird zuerst der Zustand des Base Pointers (BP), welcher auf den oberen Teil des derzeitigen Stack-Frames zeigt, auf den Stack gepushed, um diesen im Epilog wieder herstellen zu können. Danach wird der BP mit dem Wert des SP überschrieben, d.h. BP und SP zeigen beide auf den alten BP auf dem Stack. Danach werden 16 Bytes (0x10) für die Variablen und Parameter von main auf dem Stack alloziert, indem der SP um die entsprechende Anzahl an Bytes verringert wird. Innerhalb des allozierten Speicherbereichs wird die Variable `i` mit dem Wert 0 initialisiert. Die Adresse der Variable `i` (BP - 8) wird an die Funktion `foo()` mittels des RDI Registers übergeben #footnote[Wer mehr über Assembler-Programmierung lernen möchte, dem empfehle ich das Buch ,,x86-64 Assembly Language Programming with Ubuntu'' von Ed Jorgensen. Diese ist öffentlich zugänglich und bietet einen sehr guten und verständlichen Einstieg.].

#tip-box([
    In einer kompilierten Anwendung existieren Variablen nur implizit, d.h. es gibt keine Symbole oder ähnliches mit denen z.B. die Variable `i` klar identifiziert werden kann. In Assembler ist eine Variable lediglich ein Bereich im (Haupt-)Speicher in welchem der Wert der Variable gespeichert ist.
])

#figure(
  image("../images/chapter01/stack1.png", width: 80%),
  caption: [
    Stack-Frame von `main()`
  ],
)

```asm
00000000010348e0 <stack_01.foo>:
 10348e0: push   rbp
 10348e1: mov    rbp,rsp
 10348e4: sub    rsp,0x20
 10348e8: mov    QWORD PTR [rbp-0x18],rdi
 10348ec: mov    QWORD PTR [rbp-0x8],rdi
 10348f0: mov    rax,QWORD PTR [rdi]
 10348f3: add    rax,0x1
 10348f7: mov    QWORD PTR [rbp-0x10],rax
 10348fb: setb   al
 10348fe: jb     1034902 <stack_01.foo+0x22>
 1034900: jmp    1034924 <stack_01.foo+0x44>
 1034902: movabs rdi,0x101ed99
 1034909:       00 00 00 
 103490c: mov    esi,0x10
 1034911: xor    eax,eax
 1034913: mov    edx,eax
 1034915: movabs rcx,0x101dfb0
 103491c:       00 00 00 
 103491f: call   1034940 <builtin.default_panic>
 1034924: mov    rax,QWORD PTR [rbp-0x18]
 1034928: mov    rcx,QWORD PTR [rbp-0x10]
 103492c: mov    QWORD PTR [rax],rcx
 103492f: xor    eax,eax
 1034931: add    rsp,0x20
 1034935: pop    rbp
 1034936: ret
```

Nach dem Aufruf von `foo()` wird zuerst ein neuer Stack-Frame für den Funktionsaufruf erzeugt. Innerhalb dieses Stack-Frames wird der Parameter `a` mit der Adressen von `i` initialisiert. Was auffällt ist, dass die in RDI gespeicherte Adresse gleich mehrmals auf den Stack geschrieben wird und zusätzlich direkt dereferenziert wird um den Wert von `i` in das Regsiter RAX zu laden. Schaut man sich jedoch den gesamten Funktionskörper an so sieht man, dass von der Speicherstelle BP - 24 die Adresse von `i` zum Zurückschreiben des inkrementierten Werts geladen wird. Damit ist BP - 24 in diesem Fall der Parameter `a`. Dementsprechend sieht der Stack nach aufruf von `foo()` wie folgt aus.

#figure(
  image("../images/chapter01/stack2.png", width: 25%),
  caption: [
    Stack-Frame von `foo()`
  ],
)

Diese im Funktionsprolog vollzogenen Schritte werden vor dem Verlassen der Funktion, im Epilog, umgekehrt, d.h. beim ausführen der ret Instruktion befindet sich der Stack, bezogen auf sein Layout, im selben Zustand wie vor dem Fuktionsaufruf. Was sich natürlich geändert hat ist der Wert der Variable `i`.

=== Dynamic Memory

Wir haben uns die Allokation von dynamischem Speicher anhand des `GeneralPurposeAllocator` am Anfang dieses Kapitels schon etwas angeschaut. Die Lifetime von dynamsich allozierten Objekten ist etwas tückischer als die von statisch oder automatisch allozierten. Der Grund ist, dass bei komplexeren Programmen sowohl die Allokation als auch die Deallokation eines Objekts an verschiedenen Stellen im Code passieren kann, z.B. abhängig von einer Bedingung. 

Ein Beispiel hierfür ist eine verkettete Liste, bei der alle Element dynamisch auf dem Heap alloziert werden. Bezogen auf die Allokation würde es in diesem Szenario mindestens eine Stelle geben und zwar der Bereich des Codes, in dem ein neues Listenelement erzeugt wird. Bei der Deallokation eines Elements muss zumindest unterschieden werden, ob ein Element aus der Liste entfernt wird oder ob die gesamte Liste, zum Ende des Programms, dealloziert werden soll, wobei letzteres als ein Sonderfall angesehen werden kann. Ein weiterer Aspekt auf den geachtet werden muss ist, dass nach dem Löschen eines Elements der Liste, alle Referenzen auf dieses Element invalide sind, d.h. es darf nicht mehr auf den Speicher zugegriffen werden.

#figure(
  image("../images/chapter01/stack3.png", width: 80%),
  caption: [
    Beispiel einer verketteten Liste
  ],
)

```zig
// chapter03/linked-list.zig
const std = @import("std");

// Element einer verketteten Liste mit zwei (optionalen)
// Zeigern auf das nächste und vorherige Element.
const Elem = struct {
    prev: ?*Elem = null,
    next: ?*Elem = null,
    i: u32,

    pub fn new(i: u32, allocator: std.mem.Allocator) !*@This() {
        var self = try allocator.create(@This());
        self.i = i;
        return self;
    }
};

pub fn main() !void {
    // Hier fassen wir die Erzeugung eines neune Allokator-Typen
    // und dessen Instanziierung in einen Ausdruck zusammen...
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // ... und binden dann den Allokator an eine Konstante.
    const allocator = gpa.allocator();

    // Als nächstes erzeugen wir (manuell) eine verkettete
    // Liste mit drei Elementen.
    var lhs = try Elem.new(1, allocator);
    defer allocator.destroy(lhs);
    var middle = try Elem.new(2, allocator);
    var rhs = try Elem.new(3, allocator);
    defer allocator.destroy(rhs);

    lhs.next = middle;
    middle.prev = lhs;

    middle.next = rhs;
    rhs.prev = middle;
    
    // Die Konstante L referenziert das erste Element aus
    // der Liste (`lhs`).
    const L = lhs;
    // Ausgehend vom ersten Element geben wir alle Werte der
    // Liste nacheinander aus.
    std.log.info("Wert von lhs: {d}", .{L.i});
    std.log.info("Wert von middle: {d}", .{L.next.?.i});
    std.log.info("Wert von rhs: {d}", .{L.next.?.next.?.i});
    
    // Die Konstante `x` referenziert das mittlere Element...
    const x = middle;
    std.log.info(
    "Wert von Elem referenziert von x vor deallokation: {d}", 
    .{x.i});

    // ... welches als nächstes aus der Liste (manuell) entfernt wird.
    lhs.next = middle.next;
    rhs.prev = middle.prev;
    allocator.destroy(middle);
    // ... ab diesem Zeitpunkt ist `x` ein dangling Pointer und
    // darf nicht mehr dereferenziert werden...
    
    // ... wir machen es trotzdem aber der Wert des referenzierten
    // Objekts ist ab diesem Zeitpunkt undefiniert.
    std.log.info(
    "Wert von Elem referenziert von x NACH deallokation: {d}", 
    .{x.i});
}
```

In folgendem Beispiel erzeugen wir eine verkettete Liste mit drei Elementen. Als nächstes definieren wir eine Konstante `L`, die das erste Element der Liste `lhs` referenziert und geben nach und nach, durch Dereferenzierung, die Werte aller drei Elemente aus. Da weder `lhs`, `middle` noch `rhs` bis zum Zeitpunkt der Ausgabe dealloziert wurden, ist die Dereferenzierung erlaubt. Wie Sie vielleicht gesehen haben ist die dritte Ausgabe, die letzte Stelle an der `L` dereferenziert wird. Damit überschreitet die Lifetime von L zwar theoretisch die Lifetime von `lhs`, `middle` und `rhs`, in der Praxis spielt dies für die Korrektheit der Anwendung jedoch keine Rolle. Anders sieht es mit der Konstanten `x` aus. Zwischen der ersten und zweiten Dereferenzierung von `x` wird `middle` aus der Liste entfernt und dealloziert. Damit ist `x` ab der Deallokation von middle ein dangling Pointer was zum Problem wird, da `x` später noch einmal derefernziert wird. Auch nach der Deallokation zeigt `x` weiterhin auf eine existierende Speicherstelle, jedoch wurde diese durch die Deallokation freigegeben, d.h. die Daten an dieser Stelle sind undefiniert. Das hält Zig jedoch nicht davon ab den referenzierten Speicher als Instanz von Elem zu interpretieren, was sich auch in der Kommandozeilenausgabe widerspiegelt.

```bash
$ ./linked-list
info: Wert von lhs: 1
info: Wert von middle: 2
info: Wert von rhs: 3
info: Wert von Elem ... von x vor deallokation: 2
info: Wert von Elem ... von x NACH deallokation: 2863311530
```

Diese Art von Speicherfehler wird als Use-After-Free bezeichnet und kann unter den richtigen Bedingungen von Angreifern genutzt werden, den Kontrollfluss des Programms zu übernehmen, sollte es für den Angreifer möglich sein die Speicherstelle zu kontrollieren.

Etwas das Sie sich grundsätzlich Angewöhnen sollten ist, Referenzen die Sie nicht mehr benötigen zu invalidieren. Eine Möglichkeit dies zu tun ist anstelle eines Pointers einen optionalen Pointer zu verwenden.

```zig
var x: ?*Elem = middle;
// ...
lhs.next = middle.next;
rhs.prev = middle.prev;
allocator.destroy(middle);
x = null; // wir invalidieren x direkt nach der Deallokation
```

== Häufige Fehler

Im Gegensatz zu speichersicheren (engl. memory safe) Sprachen wie etwa Rust, bietet Zig einige Fallstricke, die das Leben als Entwickler schwer machen können, aber nicht müssen! In diesem Abschnitt werden wir uns einige davon näher anschauen und ich zeigen Ihnen, wie Zig Ihnen dabei hilft sicheren Code zu schreiben.

=== Speicherzugriffsfehler (Access Errors)

Speicherzugriffsfehler sind eine typische Fehlerquelle und haben in der Vergangenheit schon zu so einigen Exploits geführt. Allgemein handelt es sich dabei um einen Oberbegriff für Programmierfehler, durch die unzulässig auf eine Speicherstelle zugegriffen wird. Zu den Speicherzugriffsfehlern gehören der Buffer-Overflow, Buffer-Over-Read, Invalid-Page-Fault und Use-After-Free. Den Use-After-Free haben wir uns im Kontext von Lifetimes schon angeschaut, an dieser Stelle möchte ich Ihnen die verbleibenden Fehler etwas näher bringen.

==== Buffer Overflow/ Over-Read

Der Buffer-Overflow und Buffer-Over-Read sind nah miteinander verwandt, kommen jedoch jeweils mit ihren eigenen Problemen. Beim Buffer-Overflow wird Speicher außerhalb eines validen Objekts beschrieben. Dies ist meist das Resultat der unzureichenden Überprüfung der Grenzen eines Objekts, z.B. eines Arrays. Ein klassisches Beispiel ist ein Array, dass an einer Stelle indiziert wird die außerhalb der Grenzen des Arrays liegt.

```zig
var x: [10]u8 = .{0} ** 10;
x[10] = 1; // Index 10 ist out-of-bounds -> buffer overrread!
```

Diese Art von Fehlern können genutzt werden um Daten von naheliegenden Objekten oder sogar Adressen zu überschreiben. In der Vergangenheit wurde diese Art von Fehler von Angreifern genutzt um Schadcode in Anwendungen einzuschleusen, die Rücksprungadresse zu überschreiben und so die Kontrolle über den Prozess zu übernehmen. Moderne Compiler injizieren deswegen sogenannte Stack-Canaries, einen randomisierten Wert der von einem Angreifer nicht erraten werden kann und der vor der Rückkehr in die aufrufende Funktion überprüft wird, in Stack-Frames die potenziell von einem Buffer-Overflow betroffen sein könnten. Ist ein Stack-Frame von einem Buffer-Overflow betroffen und wurde die Rücksprungadresse überschrieben, so bedeutet dies, dass auch der Canary überschrieben wurde. In diesem Fall wird der Prozess zur Sicherheit beendet. Wie das Zig-Zen so schön sagt: ,,Laufzeit-Crashes sind besser als Bugs'' (engl. "Runtime crashes are better than bugs").

Im obigen Fall wird der Buffer-Overflow schon zur Compile-Zeit erkannt, da Arrays eine zur Compile-Zeit bekannte Länge besitzen (Zig-Zen: "Compile errors are better than runtime crashes").

```bash
error: index 10 outside array of length 10
    x[10] = 1;
```

Allozieren wir den Speicher jedoch dynamisch so kann der Compiler uns nicht mehr vor unserem Fehler bewahren. 

```zig
var x = try allocator.alloc(u8, 10);
x[10] = 1;
```

Da wir in Zig jedoch in den meisten Fällen mit Slices arbeiten und nicht mit rohen Zeigern wird der Buffer-Overflow zumindest zur Laufzeit erkannt und der Prozess beendet (Zig-Zen: "Runtime crashes are better than bugs").

```bash
thread 7940 panic: index out of bounds: index 10, len 10
buffer-overflow.zig:12:6: 0x1037424 in main (buffer-overflow)
    x[10] = 1;
```

==== Invalid Page Fault

== Zusammenfassung

Bei dem Arbeiten mit Referenzen bzw. Slices sind zwei Fragen von essenzieller Bedeutung: Umschließt die Lifetime des referenzierten Objekts die der Referenz und wenn nein, habe ich dafür gesorgt, dass nach dem Ende der Lifetime des Objekts nicht mehr versucht wird auf dieses zuzugreifen. Fall Sie diese Fragen nicht beantworten können besteht eine hohe Wahrscheinlichkeit, dass sich Speicherfehler in Ihren Code einschleichen.

