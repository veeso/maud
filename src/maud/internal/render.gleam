//// Render module which takes a Markdown document and the configuration and produces a Lustre component tree.

import gleam/dict
import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import maud/components.{type Components}
import mork/document.{type Block, type Document, type Inline}

/// Recursive function to render a list of blocks into a list of Lustre elements, using the provided components configuration.
///
/// Top-level blocks always use `document.Loose` packing so that paragraphs
/// are wrapped in `<p>` tags. The `Tight` packing is only applied inside
/// tight list items, where `render_list_item` handles it directly.
pub fn render_blocks(
  blocks: List(Block),
  document: Document,
  components: Components(a),
) -> List(Element(a)) {
  list.map(blocks, fn(block) {
    render_block(block, document, components, document.Loose)
  })
}

/// Render footnotes at the end of the document, sorted by their reference key.
/// 
/// Footnotes are rendered after all blocks, so they will appear at the end of the output.
/// If you want to render footnotes in a different location, you can call this function directly
pub fn footnote(
  acc: List(Element(a)),
  document: Document,
  components: Components(a),
) -> List(Element(a)) {
  document.footnotes
  |> dict.to_list()
  |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
  |> list.map(fn(tup) { tup.1 })
  |> list.flat_map(fn(doc) { render_blocks(doc.blocks, document, components) })
  |> fn(footnotes) { list.append(acc, footnotes) }
}

/// Render a single block into a Lustre element using the appropriate component function from `Components(a)`.
/// 
/// See <https://git.liten.app/krig/mork/src/commit/a50990c84196c1d5575974c76dbfb2f7795c2b24/to_lustre/src/mork/to_lustre.gleam#L154>
fn render_block(
  block: Block,
  document: Document,
  components: Components(a),
  pack: document.ListPack,
) -> Element(a) {
  case block {
    document.BlockQuote(blocks) ->
      render_blockquote(blocks, document, components)
    document.BulletList(pack: pack, items: items) ->
      render_ul(pack, items, document, components)
    document.Code(lang: lang, text: text) -> render_pre(lang, text, components)
    document.Heading(level: level, id: id, raw: _, inlines: inlines) ->
      render_heading(level, id, inlines, document, components)
    document.HtmlBlock(raw: raw) -> element.unsafe_raw_html("", "div", [], raw)
    document.Newline | document.Empty -> element.none()
    document.OrderedList(pack: pack, items: items, start: start) ->
      render_ol(start, pack, items, document, components)
    document.Paragraph(raw: _, inlines: inlines) ->
      render_paragraph(pack, inlines, document, components)
    document.Table(header: header, rows: rows) ->
      render_table(header, rows, document, components)
    document.ThematicBreak -> render_thematic_break(components)
  }
}

/// Render a list of inlines into a list of Lustre elements by mapping each inline to its corresponding component function.
fn render_inlines(
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> List(Element(a)) {
  list.map(inlines, fn(inline) { render_inline(document, inline, components) })
}

/// Render a single inline element into a Lustre element using the appropriate component function from `Components(a)`.
/// 
/// See <https://git.liten.app/krig/mork/src/commit/a50990c84196c1d5575974c76dbfb2f7795c2b24/to_lustre/src/mork/to_lustre.gleam#L397>
fn render_inline(
  document: Document,
  inline: Inline,
  components: Components(a),
) -> Element(a) {
  case inline {
    document.Autolink(uri: uri, text: text) ->
      render_autolink(uri, text, components)
    document.CodeSpan(text) ->
      components.code(dict.new(), option.None, [element.text(text)])
    document.EmailAutolink(mail: email) ->
      render_autolink("mailto:" <> email, option.Some(email), components)
    document.Emphasis(inlines) -> render_emphasis(inlines, document, components)
    document.Footnote(num: num, label: label) ->
      render_footnote(num, [element.text(label)], components)
    document.FullImage(text: inlines, data: image) ->
      render_img(inlines, image, document, components)
    document.FullLink(text: inlines, data: link_data) ->
      render_a(inlines, link_data, document, components)
    document.HardBreak -> html.br([])
    document.Highlight(inlines) ->
      render_highlight(inlines, document, components)
    document.InlineFootnote(num: num, text: inlines) ->
      render_footnote(
        num,
        render_inlines(inlines, document, components),
        components,
      )
    document.InlineHtml(tag: tag, attrs: attributes, children: inlines) ->
      render_inline_html(tag, attributes, inlines, document, components)
    document.RawHtml(_) -> element.none()
    document.RefImage(text: inlines, label: label) ->
      case dict.get(document.links, label) {
        Ok(link_data) -> render_img(inlines, link_data, document, components)
        Error(_) ->
          render_img(
            inlines,
            document.LinkData(dest: document.Absolute(""), title: option.None),
            document,
            components,
          )
      }
    document.RefLink(text: inlines, label: label) ->
      case dict.get(document.links, label) {
        Ok(link_data) -> render_a(inlines, link_data, document, components)
        Error(_) ->
          render_a(
            inlines,
            document.LinkData(dest: document.Absolute(""), title: option.None),
            document,
            components,
          )
      }
    document.SoftBreak -> element.text("\n")
    document.Strikethrough(inlines) ->
      render_strikethrough(inlines, document, components)
    document.Strong(inlines) -> render_strong(inlines, document, components)
    document.Text(text) -> element.text(text)
    document.Checkbox(checked: checked) -> render_checkbox(checked, components)
    document.Delim(style: style, len: len, can_open: _, can_close: _) ->
      element.text(string.repeat(style, len))
  }
}

/// Render a link by extracting the destination URI and title from the `link_data`, rendering the child inlines as the link text, and passing them to the `a` component function.
fn render_a(
  inlines: List(Inline),
  link_data: document.LinkData,
  document: Document,
  components: Components(a),
) -> Element(a) {
  let href = src(link_data.dest)
  inlines
  |> render_inlines(document, components)
  |> fn(children) { components.a(dict.new(), href, link_data.title, children) }
}

/// Render an autolink by using the URI as the href and the optional text as the link text, passing them to the `a` component function.
fn render_autolink(
  uri: String,
  text: Option(String),
  components: Components(a),
) -> Element(a) {
  components.a(dict.new(), uri, option.None, [
    element.text(option.unwrap(text, or: uri)),
  ])
}

/// Render a blockquote by rendering its child blocks and passing them to the `blockquote` component function.
fn render_blockquote(
  blocks: List(Block),
  document: Document,
  components: Components(a),
) -> Element(a) {
  // Mork's CommonMark `Block` type does not carry block attributes, so an empty
  // dictionary is passed. The argument exists so callers relying on attributes
  // (e.g. a Djot-based pipeline) share the same `Components` shape.
  let children = render_blocks(blocks, document, components)
  components.blockquote(dict.new(), children)
}

/// Render a checkbox inline by passing the checked state to the `checkbox` component function.
fn render_checkbox(checked: Bool, components: Components(a)) -> Element(a) {
  components.checkbox(checked)
}

/// Render an emphasis (italic) inline by rendering its child inlines and passing them to the `em` component function.
fn render_emphasis(
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  inlines
  |> render_inlines(document, components)
  |> components.em()
}

/// Render a footnote reference by passing the footnote number and label to the `footnote` component function.
fn render_footnote(
  num: Int,
  children: List(Element(a)),
  components: Components(a),
) -> Element(a) {
  components.footnote(num, children)
}

/// Render a heading by rendering its child inlines and passing them to the appropriate heading component function based on the heading level.
fn render_heading(
  level: Int,
  id: String,
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  let children = render_inlines(inlines, document, components)
  // Mork does not expose heading attributes, so an empty dictionary is passed.
  let attributes = dict.new()
  case level {
    1 -> components.h1(attributes, id, children)
    2 -> components.h2(attributes, id, children)
    3 -> components.h3(attributes, id, children)
    4 -> components.h4(attributes, id, children)
    5 -> components.h5(attributes, id, children)
    _ -> components.h6(attributes, id, children)
  }
}

/// Render a highlight inline by rendering its child inlines and passing them to the `mark` component function.
fn render_highlight(
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  inlines
  |> render_inlines(document, components)
  |> components.mark()
}

/// Render an image by extracting the source URI and alt text from the link
/// data and inlines, and passing them to the `img` component function.
fn render_img(
  inlines: List(Inline),
  link_data: document.LinkData,
  _document: Document,
  components: Components(a),
) -> Element(a) {
  let uri = src(link_data.dest)
  let alt = inlines_to_text(inlines)
  components.img(dict.new(), uri, alt, link_data.title)
}

/// Render an inline HTML element by creating a Lustre element with the given tag, attributes, and children.
fn render_inline_html(
  tag: String,
  attributes: dict.Dict(String, String),
  children: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  element.element(
    tag,
    html_attributes(attributes),
    render_inlines(children, document, components),
  )
}

/// Render an ordered list by rendering each list item wrapped in `<li>` and
/// passing them to the `ol` component function.
fn render_ol(
  start: Option(Int),
  pack: document.ListPack,
  items: List(document.ListItem),
  document: Document,
  components: Components(a),
) -> Element(a) {
  let children =
    items
    |> list.map(fn(item) { render_list_item(item, pack, document, components) })
  components.ol(start, children)
}

/// Render a paragraph by rendering its child inlines and passing them to the `p` component function.
///
/// When inside a tight list, paragraph content is rendered as a bare fragment
/// (no `<p>` wrapper) per the CommonMark specification.
fn render_paragraph(
  pack: document.ListPack,
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  let text = render_inlines(inlines, document, components)
  case pack {
    document.Tight -> element.fragment(text)
    document.Loose -> components.p(dict.new(), text)
  }
}

/// Render a code block by passing the language (if any) and the text to the `code` component function.
fn render_pre(
  language: Option(String),
  text: String,
  components: Components(a),
) -> Element(a) {
  components.pre(dict.new(), [
    components.code(dict.new(), language, [element.text(text)]),
  ])
}

/// Render a strikethrough inline by rendering its child inlines and passing them to the `del` component function.
fn render_strikethrough(
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  inlines
  |> render_inlines(document, components)
  |> components.del()
}

/// Render a strong (bold) inline by rendering its child inlines and passing them to the `strong` component function.
fn render_strong(
  inlines: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  inlines
  |> render_inlines(document, components)
  |> components.strong()
}

/// Render a table by rendering the header and body, then passing them to the `table` component function.
fn render_table(
  header: List(document.THead),
  rows: List(List(document.Cell)),
  document: Document,
  components: Components(a),
) -> Element(a) {
  let thead = render_thead(header, document, components)
  let aligns = list.map(header, fn(head) { head.align })
  let tbody = render_tbody(rows, aligns, document, components)
  components.table([thead, tbody])
}

/// Render the table body by rendering each row and passing them to the `tbody` component function.
fn render_tbody(
  rows: List(List(document.Cell)),
  aligns: List(document.Alignment),
  document: Document,
  components: Components(a),
) -> Element(a) {
  rows
  |> list.map(fn(cells) { render_tr(cells, aligns, document, components) })
  |> components.tbody()
}

/// Render a table row by rendering each cell and passing them to the `tr` component function with the appropriate alignment.
fn render_tr(
  cells: List(document.Cell),
  aligns: List(document.Alignment),
  document: Document,
  components: Components(a),
) -> Element(a) {
  cells
  |> list.zip(aligns)
  |> list.map(fn(pair) {
    let cell = pair.0
    let align = pair.1
    render_td(align, cell.inlines, document, components)
  })
  |> components.tr()
}

/// Render the table header by wrapping header cells in a `<tr>` inside a `<thead>`.
fn render_thead(
  headers: List(document.THead),
  document: Document,
  components: Components(a),
) -> Element(a) {
  headers
  |> list.map(fn(header) {
    render_th(header.align, header.inlines, document, components)
  })
  |> components.tr()
  |> fn(row) { components.thead([row]) }
}

/// Render a table data cell by rendering its child inlines and passing them to the `td` component function with the appropriate alignment.
fn render_td(
  alignment: document.Alignment,
  items: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  let align = mork_alignment_to_alignment(alignment)
  let children = render_inlines(items, document, components)
  components.td(align, children)
}

/// Render a table header cell by rendering its child inlines and passing them to the `th` component function with the appropriate alignment.
fn render_th(
  alignment: document.Alignment,
  items: List(Inline),
  document: Document,
  components: Components(a),
) -> Element(a) {
  let align = mork_alignment_to_alignment(alignment)
  let children = render_inlines(items, document, components)
  components.th(align, children)
}

/// Render a thematic break (horizontal rule) by calling the `hr` component function.
fn render_thematic_break(components: Components(a)) -> Element(a) {
  components.hr()
}

/// Render an unordered list by rendering each list item wrapped in `<li>` and
/// passing them to the `ul` component function.
fn render_ul(
  pack: document.ListPack,
  items: List(document.ListItem),
  document: Document,
  components: Components(a),
) -> Element(a) {
  items
  |> list.map(fn(item) { render_list_item(item, pack, document, components) })
  |> components.ul()
}

/// Helper function to extract the URI from a `document.LinkData` and return it as a string.
fn src(destination: document.Destination) -> String {
  case destination {
    document.Absolute(uri) -> uri
    document.Relative(uri) -> uri
    document.Anchor(anchor) -> "#" <> uri.percent_encode(anchor)
  }
}

/// Converts a list of key-value pairs into a list of Lustre attributes, used for rendering inline HTML elements with their attributes.
fn html_attributes(
  attributes: dict.Dict(String, String),
) -> List(attribute.Attribute(msg)) {
  attributes
  |> dict.to_list()
  |> list.map(fn(pair) { attribute.attribute(pair.0, pair.1) })
}

/// Render a single list item by processing its blocks and wrapping them in
/// the `li` component. For tight lists, paragraph inlines are extracted
/// directly to avoid `element.fragment` comment markers in output.
fn render_list_item(
  list_item: document.ListItem,
  pack: document.ListPack,
  document: Document,
  components: Components(a),
) -> Element(a) {
  list_item.blocks
  |> list.flat_map(fn(block) {
    case pack, block {
      // For tight lists, extract paragraph inlines directly without wrapping
      document.Tight, document.Paragraph(inlines: inlines, ..) ->
        render_inlines(inlines, document, components)
      // For all other cases, render the block normally
      _, _ -> [render_block(block, document, components, pack)]
    }
  })
  |> components.li()
}

/// Extract plain text from a list of inlines, used for image alt text.
fn inlines_to_text(inlines: List(Inline)) -> String {
  inlines
  |> list.map(fn(inline) {
    case inline {
      document.Text(text) -> text
      document.CodeSpan(text) -> text
      document.Emphasis(inner) -> inlines_to_text(inner)
      document.Strong(inner) -> inlines_to_text(inner)
      document.Strikethrough(inner) -> inlines_to_text(inner)
      document.Highlight(inner) -> inlines_to_text(inner)
      document.SoftBreak | document.HardBreak -> " "
      _ -> ""
    }
  })
  |> string.concat()
}

/// Convert Mork's alignment type to Maud's alignment type for use in table rendering.
fn mork_alignment_to_alignment(
  alignment: document.Alignment,
) -> components.Alignment {
  case alignment {
    document.Left -> components.Left
    document.Center -> components.Center
    document.Right -> components.Right
  }
}
