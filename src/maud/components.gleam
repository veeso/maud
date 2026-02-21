//// Customizable component configuration for rendering Markdown into Lustre elements.
////
//// This module defines the `Components` type, a record of view functions that control
//// how each Markdown construct is rendered. Use `default()` for standard HTML output,
//// or override individual components to apply custom styling.
////
//// ## Usage
////
//// ```gleam
//// import maud/components
////
//// // Use defaults
//// let c = components.default()
////
//// // Override specific components via piping
//// let c =
////   components.default()
////   |> components.h1(fn(_id, children) { html.h1([attribute.class("title")], children) })
////   |> components.p(fn(children) { html.p([attribute.class("body")], children) })
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

/// Text alignment for table cells.
pub type Alignment {
  /// Left-aligned text (the default for most table cells).
  Left
  /// Center-aligned text.
  Center
  /// Right-aligned text.
  Right
}

/// A record of view functions that control how each Markdown element is rendered.
///
/// Components are rendered bottom-up: children are rendered first, then passed
/// to the parent component function as a `List(Element(a))`. When implementing
/// a custom component, you must pass the children into the element you return,
/// otherwise they will not appear in the output.
pub type Components(a) {
  Components(
    a: fn(String, Option(String), List(Element(a))) -> Element(a),
    blockquote: fn(List(Element(a))) -> Element(a),
    checkbox: fn(Bool) -> Element(a),
    code: fn(Option(String), List(Element(a))) -> Element(a),
    del: fn(List(Element(a))) -> Element(a),
    em: fn(List(Element(a))) -> Element(a),
    footnote: fn(Int, List(Element(a))) -> Element(a),
    h1: fn(String, List(Element(a))) -> Element(a),
    h2: fn(String, List(Element(a))) -> Element(a),
    h3: fn(String, List(Element(a))) -> Element(a),
    h4: fn(String, List(Element(a))) -> Element(a),
    h5: fn(String, List(Element(a))) -> Element(a),
    h6: fn(String, List(Element(a))) -> Element(a),
    hr: fn() -> Element(a),
    img: fn(String, String, Option(String)) -> Element(a),
    li: fn(List(Element(a))) -> Element(a),
    mark: fn(List(Element(a))) -> Element(a),
    ol: fn(Option(Int), List(Element(a))) -> Element(a),
    p: fn(List(Element(a))) -> Element(a),
    pre: fn(List(Element(a))) -> Element(a),
    strong: fn(List(Element(a))) -> Element(a),
    table: fn(List(Element(a))) -> Element(a),
    tbody: fn(List(Element(a))) -> Element(a),
    td: fn(Alignment, List(Element(a))) -> Element(a),
    th: fn(Alignment, List(Element(a))) -> Element(a),
    thead: fn(List(Element(a))) -> Element(a),
    tr: fn(List(Element(a))) -> Element(a),
    ul: fn(List(Element(a))) -> Element(a),
  )
}

/// Return the default components, rendering each Markdown element as its
/// corresponding HTML element without additional attributes or styling.
///
/// ## Examples
///
/// ```gleam
/// let c = components.default()
/// ```
pub fn default() -> Components(a) {
  Components(
    a: fn(href, title, children) {
      let title_attr = case title {
        Some(t) -> [attribute.title(t)]
        None -> []
      }
      html.a([attribute.href(href), ..title_attr], children)
    },
    blockquote: default_view(html.blockquote),
    checkbox: fn(checked) {
      let attrs = case checked {
        True -> [
          attribute.type_("checkbox"),
          attribute.checked(True),
          attribute.disabled(True),
        ]
        False -> [attribute.type_("checkbox"), attribute.disabled(True)]
      }
      html.input(attrs)
    },
    code: fn(language, children) {
      case language {
        Some(lang) ->
          html.code([attribute.class("language-" <> lang)], children)
        None -> html.code([], children)
      }
    },
    del: default_view(html.del),
    em: default_view(html.em),
    footnote: fn(num, children) {
      html.sup([], [
        html.a([attribute.id("fnref-" <> int.to_string(num))], children),
      ])
    },
    h1: heading_view(html.h1),
    h2: heading_view(html.h2),
    h3: heading_view(html.h3),
    h4: heading_view(html.h4),
    h5: heading_view(html.h5),
    h6: heading_view(html.h6),
    hr: fn() { html.hr([]) },
    img: fn(uri, alt, title) {
      let alt_attr = case alt {
        "" -> []
        _ -> [attribute.alt(alt)]
      }
      let title_attr = case title {
        Some(t) -> [attribute.title(t)]
        None -> []
      }
      html.img(list.flatten([[attribute.src(uri)], alt_attr, title_attr]))
    },
    li: default_view(html.li),
    mark: default_view(html.mark),
    ol: fn(start, children) {
      case start {
        Some(s) ->
          html.ol([attribute.attribute("start", int.to_string(s))], children)
        None -> html.ol([], children)
      }
    },
    p: default_view(html.p),
    pre: default_view(html.pre),
    strong: default_view(html.strong),
    table: default_view(html.table),
    tbody: default_view(html.tbody),
    td: aligned_cell_view(html.td),
    th: aligned_cell_view(html.th),
    thead: default_view(html.thead),
    tr: default_view(html.tr),
    ul: default_view(html.ul),
  )
}

/// Set the `a` component used for links.
///
/// The first argument is the link href, the second is an optional title,
/// and the third is the list of children elements.
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.a(fn(href, _title, children) {
///   html.a([attribute.href(href), attribute.class("link")], children)
/// })
/// ```
pub fn a(
  components: Components(a),
  view: fn(String, Option(String), List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, a: view)
}

/// Set the `blockquote` component used for block quotes.
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.blockquote(fn(children) {
///   html.blockquote([attribute.class("quote")], children)
/// })
/// ```
pub fn blockquote(
  components: Components(a),
  blockquote: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, blockquote: blockquote)
}

/// Set the `checkbox` component used for task list checkboxes.
///
/// The first argument indicates whether the checkbox is checked.
pub fn checkbox(
  components: Components(a),
  checkbox: fn(Bool) -> Element(a),
) -> Components(a) {
  Components(..components, checkbox: checkbox)
}

/// Set the `code` component used for inline code and code blocks.
///
/// The first argument is the optional language identifier (e.g. `Some("gleam")`
/// for fenced code blocks with a language tag, `None` for inline code).
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.code(fn(language, children) {
///   case language {
///     option.Some(lang) ->
///       html.code([attribute.class("lang-" <> lang)], children)
///     option.None -> html.code([attribute.class("code")], children)
///   }
/// })
/// ```
pub fn code(
  components: Components(a),
  code: fn(Option(String), List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, code: code)
}

/// Set the `del` component used for strikethrough text.
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.del(fn(children) {
///   html.del([attribute.class("strikethrough")], children)
/// })
/// ```
pub fn del(
  components: Components(a),
  del: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, del: del)
}

/// Set the `em` component used for emphasized (italic) text.
pub fn em(
  components: Components(a),
  em: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, em: em)
}

/// Set the `footnote` component used for footnote references.
///
/// The first argument is the footnote number, the second is the children elements.
///
/// Note: the default implementation renders a forward reference only (no
/// back-link from the footnote body to the reference site).
pub fn footnote(
  components: Components(a),
  footnote: fn(Int, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, footnote: footnote)
}

/// Set the `h1` component used for level 1 headings.
///
/// The first argument is the heading id, the second is the children elements.
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.h1(fn(id, children) {
///   html.h1([attribute.id(id), attribute.class("heading")], children)
/// })
/// ```
pub fn h1(
  components: Components(a),
  h1: fn(String, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h1: h1)
}

/// Set the `h2` component used for level 2 headings.
///
/// The first argument is the heading id, the second is the children elements.
pub fn h2(
  components: Components(a),
  h2: fn(String, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h2: h2)
}

/// Set the `h3` component used for level 3 headings.
///
/// The first argument is the heading id, the second is the children elements.
pub fn h3(
  components: Components(a),
  h3: fn(String, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h3: h3)
}

/// Set the `h4` component used for level 4 headings.
///
/// The first argument is the heading id, the second is the children elements.
pub fn h4(
  components: Components(a),
  h4: fn(String, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h4: h4)
}

/// Set the `h5` component used for level 5 headings.
///
/// The first argument is the heading id, the second is the children elements.
pub fn h5(
  components: Components(a),
  h5: fn(String, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h5: h5)
}

/// Set the `h6` component used for level 6 headings.
///
/// The first argument is the heading id, the second is the children elements.
pub fn h6(
  components: Components(a),
  h6: fn(String, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h6: h6)
}

/// Set the `hr` component used for thematic breaks (horizontal rules).
pub fn hr(components: Components(a), hr: fn() -> Element(a)) -> Components(a) {
  Components(..components, hr: hr)
}

/// Set the `img` component used for images.
///
/// The first argument is the image URI, the second is the alt text
/// extracted from the image's inline content, and the third is an
/// optional title.
pub fn img(
  components: Components(a),
  img: fn(String, String, Option(String)) -> Element(a),
) -> Components(a) {
  Components(..components, img: img)
}

/// Set the `li` component used for list items.
pub fn li(
  components: Components(a),
  li: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, li: li)
}

/// Set the `mark` component used for highlighted text.
pub fn mark(
  components: Components(a),
  mark: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, mark: mark)
}

/// Set the `ol` component used for ordered lists.
///
/// The first argument is an optional start number, the second is the
/// list of children elements.
pub fn ol(
  components: Components(a),
  ol: fn(Option(Int), List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, ol: ol)
}

/// Set the `p` component used for paragraphs.
pub fn p(
  components: Components(a),
  p: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, p: p)
}

/// Set the `pre` component used for preformatted code blocks.
pub fn pre(
  components: Components(a),
  pre: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, pre: pre)
}

/// Set the `strong` component used for bold text.
pub fn strong(
  components: Components(a),
  strong: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, strong: strong)
}

/// Set the `table` component used for tables.
pub fn table(
  components: Components(a),
  table: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, table: table)
}

/// Set the `tbody` component used for table body groups.
pub fn tbody(
  components: Components(a),
  tbody: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, tbody: tbody)
}

/// Set the `td` component used for table data cells.
///
/// The first argument is the column alignment, the second is the
/// list of children elements.
pub fn td(
  components: Components(a),
  td: fn(Alignment, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, td: td)
}

/// Set the `th` component used for table header cells.
///
/// The first argument is the column alignment, the second is the
/// list of children elements.
pub fn th(
  components: Components(a),
  th: fn(Alignment, List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, th: th)
}

/// Set the `thead` component used for table header groups.
pub fn thead(
  components: Components(a),
  thead: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, thead: thead)
}

/// Set the `tr` component used for table rows.
pub fn tr(
  components: Components(a),
  tr: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, tr: tr)
}

/// Set the `ul` component used for unordered lists.
pub fn ul(
  components: Components(a),
  ul: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, ul: ul)
}

// A default view function which takes a view function that expects attributes and children,
// and returns a view function that only expects children.
fn default_view(
  view: fn(List(Attribute(a)), List(Element(a))) -> Element(a),
) -> fn(List(Element(a))) -> Element(a) {
  fn(children) { view([], children) }
}

// A default heading view function which takes a view function that expects attributes and children,
// and returns a view function that expects an id and children.
fn heading_view(
  view: fn(List(Attribute(a)), List(Element(a))) -> Element(a),
) -> fn(String, List(Element(a))) -> Element(a) {
  fn(id, children) {
    case id {
      "" -> view([], children)
      _ -> view([attribute.id(id)], children)
    }
  }
}

// A default table cell view function which takes a view function that expects
// attributes and children, and returns a view function that expects an alignment
// and children.
fn aligned_cell_view(
  view: fn(List(Attribute(a)), List(Element(a))) -> Element(a),
) -> fn(Alignment, List(Element(a))) -> Element(a) {
  fn(alignment, children) {
    let align_value = case alignment {
      Left -> "left"
      Center -> "center"
      Right -> "right"
    }
    view([attribute.style("text-align", align_value)], children)
  }
}
