//// Tests for the maud public API: render_markdown and render_document.

import gleam/list
import gleam/string
import gleeunit
import lustre/element
import maud
import maud/components
import mork
import mork/document.{type Options}

pub fn main() -> Nil {
  gleeunit.main()
}

// --- Helpers ---

/// Default options for parsing (footnotes enabled, everything else off).
fn default_options() -> Options {
  mork.configure()
}

/// Options with all GFM extensions enabled.
fn extended_options() -> Options {
  mork.configure()
  |> mork.extended(True)
}

/// Render markdown with default options and default components, return HTML string.
fn render(markdown: String) -> String {
  maud.render_markdown(markdown, default_options(), components.default())
  |> list.map(element.to_string)
  |> string.concat()
}

/// Render markdown with custom options and default components, return HTML string.
fn render_with_options(markdown: String, options: Options) -> String {
  maud.render_markdown(markdown, options, components.default())
  |> list.map(element.to_string)
  |> string.concat()
}

// --- Paragraph tests ---

pub fn render_simple_paragraph_test() {
  let result = render("Hello world")
  assert result == "<p>Hello world</p>"
}

pub fn render_multiple_paragraphs_test() {
  let result = render("First paragraph.\n\nSecond paragraph.")
  assert result == "<p>First paragraph.</p><p>Second paragraph.</p>"
}

// --- Heading tests ---

pub fn render_heading_h1_test() {
  let result = render("# Heading 1")
  assert result == "<h1>Heading 1</h1>"
}

pub fn render_heading_h2_test() {
  let result = render("## Heading 2")
  assert result == "<h2>Heading 2</h2>"
}

pub fn render_heading_h3_test() {
  let result = render("### Heading 3")
  assert result == "<h3>Heading 3</h3>"
}

pub fn render_heading_h4_test() {
  let result = render("#### Heading 4")
  assert result == "<h4>Heading 4</h4>"
}

pub fn render_heading_h5_test() {
  let result = render("##### Heading 5")
  assert result == "<h5>Heading 5</h5>"
}

pub fn render_heading_h6_test() {
  let result = render("###### Heading 6")
  assert result == "<h6>Heading 6</h6>"
}

// --- Inline formatting tests ---

pub fn render_strong_text_test() {
  let result = render("**bold text**")
  assert result == "<p><strong>bold text</strong></p>"
}

pub fn render_emphasis_text_test() {
  let result = render("*italic text*")
  assert result == "<p><em>italic text</em></p>"
}

pub fn render_inline_code_test() {
  let result = render("`inline code`")
  assert result == "<p><code>inline code</code></p>"
}

pub fn render_strikethrough_text_test() {
  let result = render_with_options("~~deleted~~", extended_options())
  assert result == "<p><del>deleted</del></p>"
}

pub fn render_highlight_text_test() {
  let result = render_with_options("==highlighted==", extended_options())
  assert result == "<p><mark>highlighted</mark></p>"
}

// --- Nested inline formatting tests ---

pub fn render_strong_inside_emphasis_test() {
  let result = render("*italic and **bold***")
  assert result == "<p><em>italic and <strong>bold</strong></em></p>"
}

pub fn render_emphasis_inside_strong_test() {
  let result = render("**bold and *italic***")
  assert result == "<p><strong>bold and <em>italic</em></strong></p>"
}

pub fn render_code_inside_strong_test() {
  let result = render("**bold `code`**")
  assert result == "<p><strong>bold <code>code</code></strong></p>"
}

// --- Code block tests ---

pub fn render_fenced_code_block_test() {
  let result = render("```\nlet x = 1\n```")
  assert result == "<pre><code>let x = 1\n</code></pre>"
}

pub fn render_fenced_code_block_with_language_test() {
  let result = render("```gleam\nlet x = 1\n```")
  assert result
    == "<pre><code class=\"language-gleam\">let x = 1\n</code></pre>"
}

// --- Block quote tests ---

pub fn render_blockquote_test() {
  let result = render("> This is a quote")
  assert result == "<blockquote><p>This is a quote</p></blockquote>"
}

pub fn render_nested_blockquote_test() {
  let result = render("> outer\n>> inner")
  assert result
    == "<blockquote><p>outer</p><blockquote><p>inner</p></blockquote></blockquote>"
}

// --- List tests ---

pub fn render_unordered_list_test() {
  let result = render("- item 1\n- item 2\n- item 3")
  assert result == "<ul><li>item 1</li><li>item 2</li><li>item 3</li></ul>"
}

pub fn render_ordered_list_test() {
  let result = render("1. first\n2. second\n3. third")
  assert result == "<ol><li>first</li><li>second</li><li>third</li></ol>"
}

pub fn render_nested_unordered_list_test() {
  let result = render("- item 1\n  - nested\n- item 2")
  assert result
    == "<ul><li>item 1<ul><li>nested</li></ul></li><li>item 2</li></ul>"
}

// --- Checkbox tests (task lists) ---

pub fn render_task_list_checked_test() {
  let result = render_with_options("- [x] done task", extended_options())
  assert result == "<ul><li><input checked disabled> done task</li></ul>"
}

pub fn render_task_list_unchecked_test() {
  let result = render_with_options("- [ ] open task", extended_options())
  assert result == "<ul><li><input disabled> open task</li></ul>"
}

pub fn render_task_list_mixed_test() {
  let result = render_with_options("- [x] done\n- [ ] open", extended_options())
  assert result
    == "<ul><li><input checked disabled> done</li><li><input disabled> open</li></ul>"
}

// --- Link tests ---

pub fn render_inline_link_test() {
  let result = render("[click here](https://example.com)")
  assert result == "<p><a href=\"https://example.com\">click here</a></p>"
}

pub fn render_inline_link_with_title_test() {
  let result = render("[click](https://example.com \"My Title\")")
  assert result
    == "<p><a href=\"https://example.com\" title=\"My Title\">click</a></p>"
}

pub fn render_reference_link_test() {
  let result = render("[click here][ref]\n\n[ref]: https://example.com")
  assert result == "<p><a href=\"https://example.com\">click here</a></p>"
}

// --- Image tests ---

pub fn render_image_test() {
  let result = render("![alt text](https://example.com/image.png)")
  assert result
    == "<p><img alt=\"alt text\" src=\"https://example.com/image.png\"></p>"
}

pub fn render_image_with_title_test() {
  let result =
    render("![alt text](https://example.com/image.png \"Image Title\")")
  assert result
    == "<p><img alt=\"alt text\" src=\"https://example.com/image.png\" title=\"Image Title\"></p>"
}

// --- Thematic break tests ---

pub fn render_thematic_break_test() {
  let result = render("---")
  assert result == "<hr>"
}

pub fn render_thematic_break_with_asterisks_test() {
  let result = render("***")
  assert result == "<hr>"
}

// --- Hard line break tests ---

pub fn render_hard_line_break_test() {
  let result = render("line one  \nline two")
  assert result == "<p>line one<br>line two</p>"
}

// --- Table tests (GFM extension) ---

pub fn render_table_test() {
  let md =
    "| Header 1 | Header 2 |\n| --- | --- |\n| cell 1 | cell 2 |\n| cell 3 | cell 4 |"
  let result = render_with_options(md, extended_options())
  assert result
    == "<table><thead><tr><th style=\"text-align:left;\"> Header 1 </th><th style=\"text-align:left;\"> Header 2 </th></tr></thead><tbody><tr><td style=\"text-align:left;\"> cell 1 </td><td style=\"text-align:left;\"> cell 2 </td></tr><tr><td style=\"text-align:left;\"> cell 3 </td><td style=\"text-align:left;\"> cell 4 </td></tr></tbody></table>"
}

// --- Mixed content tests ---

pub fn render_paragraph_with_mixed_inline_test() {
  let result = render("Normal **bold** and *italic* text")
  assert result
    == "<p>Normal <strong>bold</strong> and <em>italic</em> text</p>"
}

pub fn render_heading_with_inline_formatting_test() {
  let result = render("# Hello **world**")
  assert result == "<h1>Hello <strong>world</strong></h1>"
}

pub fn render_blockquote_with_formatting_test() {
  let result = render("> **bold** quote")
  assert result == "<blockquote><p><strong>bold</strong> quote</p></blockquote>"
}

pub fn render_list_with_inline_formatting_test() {
  let result = render("- **bold** item\n- *italic* item")
  assert result
    == "<ul><li><strong>bold</strong> item</li><li><em>italic</em> item</li></ul>"
}

// --- Custom components test ---

pub fn render_markdown_with_custom_component_test() {
  let custom_components =
    components.default()
    |> components.p(fn(children) { element.element("div", [], children) })

  let result =
    maud.render_markdown("Hello", default_options(), custom_components)
    |> list.map(element.to_string)
    |> string.concat()
  assert result == "<div>Hello</div>"
}

// --- render_document test ---

pub fn render_document_with_parsed_document_test() {
  let document =
    mork.configure()
    |> mork.parse_with_options("# Title")
  let result =
    maud.render_document(document, components.default())
    |> list.map(element.to_string)
    |> string.concat()
  assert result == "<h1>Title</h1>"
}

// --- Empty input test ---

pub fn render_empty_markdown_test() {
  let result = render("")
  assert result == ""
}
