#let tip-box(
    tip-box-text
) = {
    block(
      //fill: luma(230),
      inset: 8pt,
      radius: 4pt,
      grid(
        columns: 2,
        gutter: 3mm,
        align(horizon, image("images/ziggy.svg", width: 2cm)),
        tip-box-text,
      ),
    ) 
}

#let code(
    code-block,
    caption: none
) = {
    block(
        [
            #if caption != none {
                align(right)[#caption]
            }
            #line(length: 100%)
            #code-block
            #line(length: 100%)
        ]
    )
}
