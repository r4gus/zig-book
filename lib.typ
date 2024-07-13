// This function gets your whole document as its `body` and formats
// it as a simple fiction book.
#let book(
  language: "en",

  // The book's title.
  title: [Book title],
    
  // The book's sub-title.
  sub-title: none,

  // The book's author.
  author: "Author",
    
  // The year the book is released
  year: 2024,
    
  // The edition text (e.g., First Edition)
  edition: "First Edition",
    
  // The ISBN (if any)
  isbn: none,

  // Place
  city: "Munich, Germany",

  // The paper size to use.
  paper-size: "us-letter",

  // A dedication to display on the third page.
  dedication: none,

  // Details about the book's publisher that are
  // display on the second page.
  publishing-info: none,
  
  // An image representing the publisher. 
  publishing-image: "images/book.svg",    

  preface: "preface.typ",

  // The book's content.
  body,
) = {
  // Set the document's metadata.
  set document(title: title, author: author)

  // Set the body font. TeX Gyre Pagella is a free alternative
  // to Palatino.
  set text(font: "TeX Gyre Pagella", size: 12pt, lang: language)

  // Configure the page properties.
  set page(
    paper: paper-size,
    margin: (bottom: 1.75cm, top: 2.25cm),
  )

  // The first page.
  page(
    margin: (top: 5cm),
    [
        #place(
            top + right,
            [
                #line(length: 100%)
                #text(3.5em)[*#title*]
                #v(2em, weak: true)
                #text(1.8em, [*#sub-title*])
            ]
        )
        #place(
            bottom + right,
            [
                #text(1.6em, [*#author*])
            ]
        )
    ]
  )

  // Display publisher info at the bottom of the second page.
  align(
    top + left, 
    [
      #text(1.2em)[*#title*]
      #v(0.8em, weak: true)
      #text(1em, author)
      #v(1.5em, weak: true)
      #text(1em, [Copyright © #year #author. All rights reserved.])
      #v(1.5em, weak: true)
      #text(1em, [#city #year: #edition])
      #if isbn != none {
        v(1.5em, weak: true)
        text(1em, [ISBN: #isbn])
      }
    ]
  )
  if publishing-info != none {
    align(
        center + bottom, 
        image(publishing-image, width: 20%)
    )
    align(
        center + bottom, 
        text(0.8em, publishing-info)
    )
  }

  pagebreak()

  // Display the dedication at the top of the third page.
  if dedication != none {
    v(15%)
    align(center, strong(dedication))
  }

  // Books like their empty pages.
  pagebreak(to: "odd")

  // Configure paragraph properties.
  set par(leading: 0.68em, first-line-indent: 0pt, justify: true)
  show par: set block(spacing: 1em)

  // Start with a chapter outline.
  outline(title: [Chapters])

  pagebreak(to: "odd")

  // Preface
  page(
    [
        #place(
            top + right,
            [
                #line(length: 100%)
                #text(2.5em, weight: 700, [
                #if language == "de" {
                  "Vorwort"
                } else {
                  "Preface"
                }
                ]) 
            ]
        )
        
        #v(25%)
        #include preface
    ]
  )
  
  // Configure page properties.
  set page(
    numbering: "1",

    // The header always contains the book title on odd pages and
    // the chapter title on even pages, unless the page is one
    // that starts a chapter (the chapter title is obvious then).
    header: locate(loc => {
      // Are we on an odd page?
      let i = counter(page).at(loc).first()
      if calc.odd(i) {
        return text(0.95em, smallcaps(title))
      }

      // Are we on a page that starts a chapter? (We also check
      // the previous page because some headings contain pagebreaks.)
      let all = query(heading, loc)
      if all.any(it => it.location().page() in (i - 1, i)) {
        return
      }

      // Find the heading of the section we are currently in.
      let before = query(selector(heading).before(loc), loc)
      if before != () {
        align(right, text(0.95em, smallcaps(before.last().body)))
      }
    }),
  )

  // Configure chapter headings.
  show heading.where(level: 1): it => {
    // Always start on odd pages.
    pagebreak(to: "odd")

    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    

    v(5%)
      align(
        top + right, 
        [
          #text(2em, weight: 400, block([
            #if text.lang == "de" {
              "Kapitel"
            } else {
              "Chapter"
            }
            #counter(heading).display()
          ]))
          #line(length: 100%)
          #text(2em, weight: 700, block([#number #it.body]))
        ]
      )
     v(1.25em)
  }
  show heading: set text(11pt, weight: 400)
  
  // Page numbering starts with the first chapter 
  counter(page).update(1)
  counter(heading).update(1)
  body
}
