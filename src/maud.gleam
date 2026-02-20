//// An MDX-inspired Markdown renderer for Lustre and Gleam.
////
//// Maud turns Markdown text into a Lustre component tree, giving you full
//// control over how each Markdown construct is rendered. It uses
//// [mork](https://hexdocs.pm/mork/) for parsing and
//// [lustre](https://hexdocs.pm/lustre/) for the element model.
////
//// Both `lustre` and `mork` are required peer dependencies and must be added
//// to your project alongside `maud`.
////
//// ## Quick start
////
//// ```gleam
//// import maud
//// import maud/components
//// import mork/document
////
//// // Render with default HTML components
//// let elements =
////   maud.render_markdown(
////     "# Hello, world!\n\nThis is **maud**.",
////     document.default_options(),
////     components.default(),
////   )
//// ```
////
//// ## Custom components
////
//// Override individual components to apply your own styling:
////
//// ```gleam
//// import lustre/attribute
//// import lustre/element/html
//// import maud
//// import maud/components
//// import mork/document
////
//// let my_components =
////   components.default()
////   |> components.h1(fn(children) {
////     html.h1([attribute.class("text-4xl font-bold")], children)
////   })
////   |> components.p(fn(children) {
////     html.p([attribute.class("leading-relaxed")], children)
////   })
////
//// let elements =
////   maud.render_markdown(
////     "# Styled heading\n\nStyled paragraph.",
////     document.default_options(),
////     my_components,
////   )
//// ```

import lustre/element.{type Element}
import maud/components.{type Components}
import maud/internal/render
import mork
import mork/document.{type Document, type Options}

/// Render a pre-parsed mork `Document` into a list of Lustre elements using
/// the given `components` configuration.
///
/// Children are rendered bottom-up: each leaf is converted first, then passed
/// to its parent component function from `Components(a)`.
///
/// ## Examples
///
/// ```gleam
/// import maud
/// import maud/components
/// import mork
/// import mork/document
///
/// let document = mork.parse_with_options(document.default_options(), "# Hi")
/// let elements = maud.render_document(document, components.default())
/// ```
pub fn render_document(
  document: Document,
  components: Components(a),
) -> List(Element(a)) {
  render.render_loop(document.blocks, components)
  |> render.footnote(document, components)
}

/// Parse a Markdown string and render it into a list of Lustre elements.
///
/// This is a convenience function that combines `mork.parse_with_options`
/// and `render_document` in a single call. Use `render_document` directly
/// when you need to inspect or transform the parsed document before rendering.
///
/// ## Examples
///
/// ```gleam
/// import maud
/// import maud/components
/// import mork/document
///
/// let elements =
///   maud.render_markdown(
///     "Hello **world**",
///     document.default_options(),
///     components.default(),
///   )
/// ```
pub fn render_markdown(
  markdown: String,
  render_options: Options,
  components: Components(a),
) -> List(Element(a)) {
  render_options
  |> mork.parse_with_options(markdown)
  |> render_document(components)
}
