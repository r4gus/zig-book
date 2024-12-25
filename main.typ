#import "lib.typ": book

#show: book.with(
  language: "de",
  title: [Zig Basics],
  sub-title: [Zig programmieren für Einsteiger],
  author: "David Pierre Sugar",
  dedication: [Für Franzi und Pierre.],
  publishing-info: [
    Self Publishers Worldwide \
    Seattle San Francisco New York \
    London Paris Rome Beijing Barcelona
  ],
)

#include "chapters/chapter01.typ"
#include "chapters/chapter02.typ"
#include "chapters/chapter03.typ"
#include "chapters/case_calculator.typ"
#include "chapters/chapter04.typ"
