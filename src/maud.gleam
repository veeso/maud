//// A MDX inspired Markdown renderer for Lustre and Gleam.

import lustre/element.{type Element}
import maud/components.{type Components}
import mork
import mork/document.{type Document, type Options}

/// Renders a Markdown mork `Document` into a Lustre component tree, using the provided `Components`.
pub fn render_document(
  document: Document,
  components: Components(a),
) -> Element(a) {
  todo
}

/// Renders a Markdown content into a Lustre component tree, using the provided render options,
/// and `Components` configuration.
pub fn render_markdown(
  markdown: String,
  render_options: Options,
  components: Components(a),
) -> Element(a) {
  render_options
  |> mork.parse_with_options(markdown)
  |> render_document(components)
}
