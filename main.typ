#import "lib.typ": book

#show: book.with(
  language: "de",
  title: [Zig Basics],
  sub-title: [Systemprogrammierung für das 21. Jahrhundert],
  author: "David Pierre Sugar",
  dedication: [Für Franzi und meinen Vater Pierre, der mir Ruby gezeigt hat.],
  publishing-info: [
    Self Publishers Worldwide \
    Seattle San Francisco New York \
    London Paris Rome Beijing Barcelona
  ],
)

#include "chapters/chapter01.typ"
#include "chapters/chapter02.typ"
#include "chapters/chapter03.typ"
#include "chapters/chapter04.typ"
