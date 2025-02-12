This function gets your whole document as its `body` and formats
// it as an article in the style of the IEEE.
#let resume(
  // The paper's title.
  title: "Paper Title",

  // An array of information. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  
  information: (),

  // The paper`s author.
  

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "a4",

  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography-file: none,

  // The paper's content.
  body
) = {
  // Set document metadata.
  set document(title: title, author: information.map(author => author.name))

  // Set the body font.
  set text(font: (
    // "Times New Roman",
    "Nimbus Roman",
    // "Hiragino Mincho ProN",
    // "MS Mincho",
    // "Yu Mincho",
    "Noto Serif CJK JP",
    ), size: 12pt)
  

  // Configure the page.
  set page(
    paper: paper-size,
    header:
    locate(loc => {
      if loc.page() == 1 {
        [
          #align(center)[*#datetime.today().year().#datetime.today().month()*: *Resume for master's thesis*]
        ]
      } else if loc.page() == counter(page).final(loc).at(0) {
        [
          *#datetime.today().year().#datetime.today().month()*
          #h(1fr)
          *Resume for master's thesis*
        ]
      } else {
        [
          #align(center)[ *Title*: *#title*]
        ]
      }
    }),
    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      (
        x: (50pt / 216mm) * 100%,
        top: (55pt / 279mm) * 100%,
        bottom: (64pt / 279mm) * 100%,
      )
    },
    footer: [
      #align(center)[#counter(page).display()]
    ]
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure table
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "I.1.1.")
  show heading: it => locate(
    loc => {

      // Find out the final number of the heading counter.
      let levels = counter(heading).at(loc)
      let deepest = if levels != () {
        levels.last()
      } else {
        1
      }

      set text(10pt, weight: 400)
      if it.level == 1 [
        // First-level headings are centered smallcaps.
        // We don't want to number of the acknowledgment section.
        #let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
        #set align(center)
        #set text(weight: "bold", if is-ack { 10pt } else { 12pt })
        #show: smallcaps
        #v(20pt, weak: true)
        #if it.numbering != none and not is-ack {
          numbering("I.", levels.at(0))
          h(7pt, weak: true)
        }
        #it.body
        #v(13.75pt, weak: true)
      ] else if it.level == 2 [
        // Second-level headings are run-ins.
        #set text(weight: "bold")
        #set par(first-line-indent: 0pt)
        // #set text(style: "italic")
        #v(10pt, weak: true)
        #if it.numbering != none {
          numbering("1.1", levels.at(0), levels.at(1))
          h(7pt, weak: true)
        }
        #it.body
        #v(10pt, weak: true)
      ] else [
        // Third level headings are run-ins too, but different.
        #if it.level == 3 {
          numbering( "1.1.1", levels.at(0), levels.at(1), levels.at(2))
          [ ]
        }
        #h(1em)#(it.body)
      ]
    }
  )  

  // Display the paper's title.
  v(12pt)
  align(center, text(18pt, title))


  // Display the information list.
  v(8.35mm, weak: true)
  for i in range(calc.ceil(information.len() / 3)) {
    let end = calc.min((i + 1) * 3, information.len())
    let is-last = information.len() == end
    let slice = information.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 12pt,
      ..slice.map(author => align(center, {
        text(12pt, [#author.name #footnote[#author.location] ])
        if "department" in author [
          \ #emph(author.department)
        ]
        if "organization" in author [
          \ #emph(author.organization)
        ]
        if "location" in author [
          \ #author.location
        ]
        if "email" in author [
          \ #link("mailto:" + author.email)
        ]
      }))
    )

    if not is-last {
      v(16pt, weak: true)
    }
  }
  v(40pt, weak: true)


  // Start two column mode and configure paragraph properties.
  show: columns.with(2, gutter: 12pt)
  set par(justify: true, first-line-indent: 1em)
  show par: set block(spacing: 0.65em)

  // Display abstract and index terms.
  if abstract != none [
    #set text(weight: 700)
    #h(1em) _Abstract_---#abstract

    #if index-terms != () [
      #h(1em)_Index terms_---#index-terms.join(", ")
    ]
    #v(2pt)
  ]

  // Display the paper's contents.
  body

  // Display bibliography.
  if bibliography-file != none {
    show bibliography: set text(8pt)
    bibliography(bibliography-file, title: text(10pt)[References], style: "ieee")
  }
}
