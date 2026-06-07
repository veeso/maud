# maud

[![Package Version](https://img.shields.io/hexpm/v/maud)](https://hex.pm/packages/maud)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/maud/)
[![test](https://github.com/veeso/maud/actions/workflows/test.yml/badge.svg)](https://github.com/veeso/maud/actions/workflows/test.yml)

An MDX-inspired Markdown renderer for [Lustre](https://hexdocs.pm/lustre/) and Gleam.
Maud turns Markdown text into a Lustre component tree, giving you full control over
how each Markdown construct is rendered.

Maud depends on [lustre](https://hexdocs.pm/lustre/) and [mork](https://hexdocs.pm/mork/).
Add all three packages to your project:

```sh
gleam add maud@1
gleam add lustre@5
gleam add mork@1
```

## Quick start

Render Markdown to Lustre elements with the default HTML components:

```gleam
import maud
import maud/components
import mork

pub fn main() {
  let elements =
    maud.render_markdown(
      "# Hello, world!\n\nThis is **maud**.",
      mork.configure(),
      components.default(),
    )
  // `elements` is a `List(lustre/element.Element(a))` ready to use in your Lustre app
}
```

## Custom components

Override individual components to apply your own styling via piping:

```gleam
import lustre/attribute
import lustre/element/html
import maud
import maud/components
import mork

pub fn main() {
  let my_components =
    components.default()
    |> components.h1(fn(_attributes, _id, children) {
      html.h1([attribute.class("text-4xl font-bold")], children)
    })
    |> components.p(fn(_attributes, children) {
      html.p([attribute.class("leading-relaxed")], children)
    })

  let elements =
    maud.render_markdown(
      "# Styled heading\n\nStyled paragraph.",
      mork.configure(),
      my_components,
    )
}
```

Every Markdown construct has a matching setter on `Components` (`a`, `blockquote`, `checkbox`,
`code`, `del`, `em`, `footnote`, `h1`–`h6`, `hr`, `img`, `li`, `mark`, `ol`, `p`, `pre`,
`strong`, `table`, `tbody`, `td`, `th`, `thead`, `tr`, `ul`), so you can customize exactly
what you need while keeping the defaults for everything else.

Further documentation can be found at <https://hexdocs.pm/maud>.

## Development

```sh
gleam build   # Build the project
gleam test    # Run the tests
gleam format  # Format source files
```

## License

Maud is licensed under the [MIT License](LICENSE)
