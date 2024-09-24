#import "../tip-box.typ": tip-box, code

= Control Flow

=== For-Schleifen

Es kann äußerst nützlich sein über den Inhalt eines Arrays oder Slices zu iterieren. Eine Möglichkeit dies zu tun ist mit Hilfe einer for-Schleife.

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
