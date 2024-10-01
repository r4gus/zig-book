#import "tip-box.typ": tip-box

Zig ist eine Sprache geeignet für die Systemprogrammierung.

Das alleine macht Zig nicht besonders, jedoch verheiratet Zig die Simplizität von C mit vielen modernen Features, was vor allem Neulingen, die eine systemnahe Programmiersprache lernen wollen, zugute kommt. 

Zig als Systemprogrammiersprache ist unter anderem geeignet für:

- Kryptographie
- Mikrokontrollerprogrammierung
- Dateisysteme
- Datenbanken
- Betriebssysteme
- Treiber
- Spiele
- Simulationen
- Die Entwicklung von höheren Programmiersprachen

Insbesondere Startups, aber auch große Unternehmen, haben in den letzten Jahren auf Zig als Programmiersprache und Build-System gesetzt. Darunter Uber #footnote[https://www.uber.com/en-DE/blog/bootstrapping-ubers-infrastructure-on-arm64-with-zig/], Tigerbeetle #footnote[https://tigerbeetle.com/], und ZML #footnote[https://zml.ai/]. Diese verwenden Zig in ganz unterschiedlichen Anwendungsbereichen, darunter Datenbanken und maschinellem Lernen.

In der Welt der Systemprogrammiersprachen reiht sich Zig neben C ein und verzichtet auf viele Konzepte die andere Programmiersprachen überkomplex machen, darunter Vererbung. Damit ist Zig erfrischend übersichtlich, was vor allem Einsteigern zu gute kommt, bietet jedoch auch viele Verbesserungen gegenüber C. Ein wichtiger Fokus liegt auf der Lesbarkeit des Codes, d.h. was man sieht wird vom Computer später auch tatsächlich so ausgeführt (mit Abstrichen natürlich). Insbesondere bedeutet das: keine versteckten Allokationen, bei denen die Sprache ohne Zutun des Entwicklers dynamisch Speicher alloziert. Alles was mit der Allokation von dynamischem Speicher zu tun hat ist in Zig explizit!

Fun-Fact: Während der StackOverflow 2024 Developer Survey #footnote[https://survey.stackoverflow.co/2024/] gaben $6.2%$ der Befragten an "umfangreiche Entwicklungsarbeiten" in Zig getätigt zu haben und $73.8%$ wollen die Sprache im kommenden Jahr (2025) nutzen. Damit ist Zig trotz seines Alpha-Status eine gern genutzte Programmiersprache und reiht sich von der Zahl der Anwender neben Sprachen wie Swift, Dart, Elixir und Ruby ein.

#heading(outlined: false, "Zielgruppe")

Falls Sie bereits Erfahrung mit C oder einer anderen systemnahen Programmiersprache haben und mehr über Zig erfahren wollen ist diese Buch für Sie. Wenn Sie Erfahrung mit einer höheren Programmiersprache haben und mehr über Systemprogrammierung und Zig erfahren wollen ist dieses Buch ebenfalls für Sie.

Grundsätzlich empfehle ich Ihnen parallel zum lesen dieses Buches eigene Programmierprojekte zu realisieren um praktische Erfahrung mit der Sprache zu sammeln. Beginnen Sie mit etwas einfachem, vertrauten und steigern Sie sich, sobald Sie ein Gefühl für die Sprache bekommen haben. Sie werden merken, dass die Grundlagen in Zig schnell zu erlernen sind, es gibt jedoch auch nach einiger Zeit viel zu entdecken. Sollten Sie etwas Inspiration benötigen, so kann Ihnen Project Euler #footnote[https://projecteuler.net/about] eventuell weiterhelfen.

Wichtig zu erwähnen ist, dass Zig derzeit noch nicht die Version 1.0 erreicht hat, d.h. die Sprache und damit auch die Standardbibliothek werden sich in Zukunft noch ändern. Damit kann es sein, dass bestimmte Beispiele mit einer zukünftigen Zig-Compiler-Version nicht mehr compilieren. Sollte das für Sie ein Dealbreaker sein, so empfehle ich Ihnen die Finger von diesem Buch zu lassen und zu warten bis Zig Version 1.0 veröffentlicht wurde. 

#heading(outlined: false, "Voraussetzungen")

Die Zig-Version, die in diesem Buch verwendet wird ist 0.13.0 #footnote[https://ziglang.org/download/]. Je nachdem wann Sie dieses Buch lesen kann es sein, dass diese Version nicht mehr aktuell ist. Bei Abweichungen von der angegebenen Version ist nicht garantiert, dass die in diesem Buch abgebildeten Beispiele compilieren.

Zwar sind die meisten Konzepte und Beispiele in diesem Buch unabhängig von einem bestimmten Betriebssystem und Architektur, jedoch geht das Buch grundsätzlich von einem x86_64 Linux System aus. Dies wird relevant wenn auf Assembler, Calling-Conventions und ähnliche Konzepte Bezug genommen wird, da diese immer sowohl von der Architektur als auch dem Betriebssystem abhängen. Sollte Ihr Computer eine dieser Anforderungen nicht erfüllen, so empfiehlt es sich ggf. ein virtuelle Maschine zu verwenden #footnote[https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox#1-overview].

#heading(outlined: false, "Struktur")

Die ersten drei Kapitel beschäftigen sich mit den Grundlagen der Programmiersprache Zig. Das erste Kapitel bietet anhand von Beispielen einen Überblick über die Sprache. Im zweiten Kapitel werden die grundlegenden Datentypen der Programmiersprache näher beleuchtet. In Kapitel drei wird der Leser in grundlegende Konzepte der Speicherverwaltung eingeführt, die für die korrekte und sichere Entwicklung von Anwendungen unabdingbar sind.

Im zweiten Abschnitt des Buches werden wir anhand von Fallbeispielen verschiedene Einsatzszenarios von Zig näher betrachten, darunter:

- Schreiben eines Parsers
- Breakout

Zig bietet für jede Compiler-Version zusätzliche Ressourcen zum Lernen der Sprache und als Referenz #footnote[https://ziglang.org/learn/], darunter die Language Reference und die Online-Dokumentation der Standardbibliothek. Diese können beim Entwickeln eigener Projekte aber auch beim nachvollziehen der Code-Beispiele eine große Hilfe darstellen.

#heading(outlined: false, "Konventionen")

Die folgenden Konventionen werden in diesem Buch eingehalten:

_Italic_: Markiert neue Begriffe, URLs, Email-Adressen, Dateinamen und -endungen.

`Konstanter Abstand`: Wird verwendet für Programmbeispiele, sowie zum benennen von Programmbausteinen, wie etwa Variablennamen oder Umgebungsvariablen.

*`Konstanter Abstand Fett`*: Zeigt Kommandos oder andern, vom Nutzer zu tippenden, Text.

#tip-box([Ziggy markiert einen Tipp bzw. einen Hinweis.])

#heading(outlined: false, "Code Beispiele")

Die in diesem Buch abgebildeten Code-Beispiele finden sich auf Github unter #link("todo") zum Download.

Alle Beispiele können von Ihnen ohne Einschränkung verwendet werden. Sie brauchen die Autoren nicht explizit um Genehmigung fragen. Am Schluss geht es darum Ihnen zu helfen und nicht darum Ihnen Steine in den Weg zu legen.

Zitierungen würden uns freuen, sind jedoch keinesfalls notwendig. Ein Zitat umfasst gewöhnlich Titel, Autor, Publizist und ISBN. In diesem Fall wäre dies: ,,Zig Basics by David Pierre Sugar''.

Sollten Sie Fehler im Buch oder Code finden, die nicht auf unterschiedliche Compiler-Versionen zurückzuführen sind können Sie uns mit einem Verbesserungsvorschlag kontaktieren.

#heading(outlined: false, "Fragen, Anmerkungen und Verbesserungen")

Ich habe mein Bestes getan dieses Buch so informativ und technisch korrekt wie möglich zu gestalten. Ich bin mir jedoch auch sicher, dass dieses Buch besser sein könnte als es gerade ist. Sollten Sie Fehler finden oder generell Feedback zu diesem Buch geben wollen, so können Sie mich unter david\@thesugar.de kontaktieren. Dies gibt mir die Möglichkeit dieses Buch über die Zeit zu verbessern. Es ist mir jedoch nicht immer möglich zu antworten. Nehmen Sie es sich deswegen nicht zu Herzen wenn Sie nichts von mir hören.

#heading(outlined: false, "Danksagung")

TDB
