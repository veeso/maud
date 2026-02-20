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
////   |> components.h1(fn(children) { html.h1([attribute.class("title")], children) })
////   |> components.p(fn(children) { html.p([attribute.class("body")], children) })
//// ```

import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

/// A record of view functions that control how each Markdown element is rendered.
///
/// Components are rendered bottom-up: children are rendered first, then passed
/// to the parent component function as a `List(Element(a))`. When implementing
/// a custom component, you must pass the children into the element you return,
/// otherwise they will not appear in the output.
pub type Components(a) {
  Components(
    a: fn(List(Element(a))) -> Element(a),
    blockquote: fn(List(Element(a))) -> Element(a),
    code: fn(Option(String), List(Element(a))) -> Element(a),
    del: fn(List(Element(a))) -> Element(a),
    em: fn(List(Element(a))) -> Element(a),
    h1: fn(List(Element(a))) -> Element(a),
    h2: fn(List(Element(a))) -> Element(a),
    h3: fn(List(Element(a))) -> Element(a),
    h4: fn(List(Element(a))) -> Element(a),
    h5: fn(List(Element(a))) -> Element(a),
    h6: fn(List(Element(a))) -> Element(a),
    hr: fn(List(Element(a))) -> Element(a),
    img: fn(List(Element(a))) -> Element(a),
    li: fn(List(Element(a))) -> Element(a),
    mark: fn(List(Element(a))) -> Element(a),
    ol: fn(List(Element(a))) -> Element(a),
    p: fn(List(Element(a))) -> Element(a),
    pre: fn(List(Element(a))) -> Element(a),
    span: fn(List(Element(a))) -> Element(a),
    strong: fn(List(Element(a))) -> Element(a),
    table: fn(List(Element(a))) -> Element(a),
    td: fn(List(Element(a))) -> Element(a),
    th: fn(List(Element(a))) -> Element(a),
    tr: fn(List(Element(a))) -> Element(a),
    u: fn(List(Element(a))) -> Element(a),
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
    a: default_view(html.a),
    blockquote: default_view(html.blockquote),
    code: fn(language, children) {
      case language {
        Some(lang) ->
          html.code([attribute.class("language-" <> lang)], children)
        None -> html.code([], children)
      }
    },
    del: default_view(html.del),
    em: default_view(html.em),
    h1: default_view(html.h1),
    h2: default_view(html.h2),
    h3: default_view(html.h3),
    h4: default_view(html.h4),
    h5: default_view(html.h5),
    h6: default_view(html.h6),
    hr: fn(_) { html.hr([]) },
    img: fn(_) { html.img([]) },
    li: default_view(html.li),
    mark: default_view(html.mark),
    ol: default_view(html.ol),
    p: default_view(html.p),
    pre: default_view(html.pre),
    span: default_view(html.span),
    strong: default_view(html.strong),
    table: default_view(html.table),
    td: default_view(html.td),
    th: default_view(html.th),
    tr: default_view(html.tr),
    u: default_view(html.u),
    ul: default_view(html.ul),
  )
}

/// Set the `a` component used for links.
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.a(fn(children) { html.a([attribute.class("link")], children) })
/// ```
pub fn a(
  components: Components(a),
  view: fn(List(Element(a))) -> Element(a),
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

/// Set the `h1` component used for level 1 headings.
///
/// ## Examples
///
/// ```gleam
/// components.default()
/// |> components.h1(fn(children) {
///   html.h1([attribute.class("heading")], children)
/// })
/// ```
pub fn h1(
  components: Components(a),
  h1: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h1: h1)
}

/// Set the `h2` component used for level 2 headings.
pub fn h2(
  components: Components(a),
  h2: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h2: h2)
}

/// Set the `h3` component used for level 3 headings.
pub fn h3(
  components: Components(a),
  h3: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h3: h3)
}

/// Set the `h4` component used for level 4 headings.
pub fn h4(
  components: Components(a),
  h4: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h4: h4)
}

/// Set the `h5` component used for level 5 headings.
pub fn h5(
  components: Components(a),
  h5: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h5: h5)
}

/// Set the `h6` component used for level 6 headings.
pub fn h6(
  components: Components(a),
  h6: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, h6: h6)
}

/// Set the `hr` component used for thematic breaks (horizontal rules).
pub fn hr(
  components: Components(a),
  hr: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, hr: hr)
}

/// Set the `img` component used for images.
pub fn img(
  components: Components(a),
  img: fn(List(Element(a))) -> Element(a),
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
pub fn ol(
  components: Components(a),
  ol: fn(List(Element(a))) -> Element(a),
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

/// Set the `span` component used for inline text containers.
pub fn span(
  components: Components(a),
  span: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, span: span)
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

/// Set the `td` component used for table data cells.
pub fn td(
  components: Components(a),
  td: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, td: td)
}

/// Set the `th` component used for table header cells.
pub fn th(
  components: Components(a),
  th: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, th: th)
}

/// Set the `tr` component used for table rows.
pub fn tr(
  components: Components(a),
  tr: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, tr: tr)
}

/// Set the `u` component used for underlined text.
pub fn u(
  components: Components(a),
  u: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, u: u)
}

/// Set the `ul` component used for unordered lists.
pub fn ul(
  components: Components(a),
  ul: fn(List(Element(a))) -> Element(a),
) -> Components(a) {
  Components(..components, ul: ul)
}

/// A default view function which takes a view function that expects attributes and children,
/// and returns a view function that only expects children,
fn default_view(
  view: fn(List(Attribute(a)), List(Element(a))) -> Element(a),
) -> fn(List(Element(a))) -> Element(a) {
  fn(children) { view([], children) }
}
