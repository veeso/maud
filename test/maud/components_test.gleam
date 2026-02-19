//// Tests for the maud/components module: default components and setter functions.

import lustre/attribute
import lustre/element
import lustre/element/html
import maud/components

// --- Default components tests ---

pub fn default_returns_components_test() {
  // Verify default() creates a valid Components record by calling each component.
  let c = components.default()
  let children = [element.text("test")]

  // Each component should produce a valid element without crashing.
  let _ = c.p(children)
  let _ = c.h1(children)
  let _ = c.h2(children)
  let _ = c.h3(children)
  let _ = c.h4(children)
  let _ = c.h5(children)
  let _ = c.h6(children)
  let _ = c.a(children)
  let _ = c.blockquote(children)
  let _ = c.code(children)
  let _ = c.del(children)
  let _ = c.i(children)
  let _ = c.img(children)
  let _ = c.li(children)
  let _ = c.mark(children)
  let _ = c.ol(children)
  let _ = c.ul(children)
  let _ = c.pre(children)
  let _ = c.span(children)
  let _ = c.strong(children)
  let _ = c.table(children)
  let _ = c.td(children)
  let _ = c.th(children)
  let _ = c.tr(children)
  let _ = c.u(children)
  let _ = c.hr(children)
  Nil
}

// --- Default component HTML output tests ---

pub fn default_p_produces_html_test() {
  let c = components.default()
  let result = c.p([element.text("hello")])
  assert element.to_string(result) == "<p>hello</p>"
}

pub fn default_h1_produces_html_test() {
  let c = components.default()
  let result = c.h1([element.text("title")])
  assert element.to_string(result) == "<h1>title</h1>"
}

pub fn default_h2_produces_html_test() {
  let c = components.default()
  let result = c.h2([element.text("title")])
  assert element.to_string(result) == "<h2>title</h2>"
}

pub fn default_h3_produces_html_test() {
  let c = components.default()
  let result = c.h3([element.text("title")])
  assert element.to_string(result) == "<h3>title</h3>"
}

pub fn default_h4_produces_html_test() {
  let c = components.default()
  let result = c.h4([element.text("title")])
  assert element.to_string(result) == "<h4>title</h4>"
}

pub fn default_h5_produces_html_test() {
  let c = components.default()
  let result = c.h5([element.text("title")])
  assert element.to_string(result) == "<h5>title</h5>"
}

pub fn default_h6_produces_html_test() {
  let c = components.default()
  let result = c.h6([element.text("title")])
  assert element.to_string(result) == "<h6>title</h6>"
}

pub fn default_a_produces_html_test() {
  let c = components.default()
  let result = c.a([element.text("link")])
  assert element.to_string(result) == "<a>link</a>"
}

pub fn default_strong_produces_html_test() {
  let c = components.default()
  let result = c.strong([element.text("bold")])
  assert element.to_string(result) == "<strong>bold</strong>"
}

pub fn default_i_produces_html_test() {
  let c = components.default()
  let result = c.i([element.text("italic")])
  assert element.to_string(result) == "<i>italic</i>"
}

pub fn default_del_produces_html_test() {
  let c = components.default()
  let result = c.del([element.text("deleted")])
  assert element.to_string(result) == "<del>deleted</del>"
}

pub fn default_code_produces_html_test() {
  let c = components.default()
  let result = c.code([element.text("code")])
  assert element.to_string(result) == "<code>code</code>"
}

pub fn default_pre_produces_html_test() {
  let c = components.default()
  let result = c.pre([element.text("preformatted")])
  assert element.to_string(result) == "<pre>preformatted</pre>"
}

pub fn default_blockquote_produces_html_test() {
  let c = components.default()
  let result = c.blockquote([element.text("quote")])
  assert element.to_string(result) == "<blockquote>quote</blockquote>"
}

pub fn default_ul_produces_html_test() {
  let c = components.default()
  let result = c.ul([element.text("items")])
  assert element.to_string(result) == "<ul>items</ul>"
}

pub fn default_ol_produces_html_test() {
  let c = components.default()
  let result = c.ol([element.text("items")])
  assert element.to_string(result) == "<ol>items</ol>"
}

pub fn default_li_produces_html_test() {
  let c = components.default()
  let result = c.li([element.text("item")])
  assert element.to_string(result) == "<li>item</li>"
}

pub fn default_table_produces_html_test() {
  let c = components.default()
  let result = c.table([element.text("table")])
  assert element.to_string(result) == "<table>table</table>"
}

pub fn default_tr_produces_html_test() {
  let c = components.default()
  let result = c.tr([element.text("row")])
  assert element.to_string(result) == "<tr>row</tr>"
}

pub fn default_th_produces_html_test() {
  let c = components.default()
  let result = c.th([element.text("header")])
  assert element.to_string(result) == "<th>header</th>"
}

pub fn default_td_produces_html_test() {
  let c = components.default()
  let result = c.td([element.text("cell")])
  assert element.to_string(result) == "<td>cell</td>"
}

pub fn default_mark_produces_html_test() {
  let c = components.default()
  let result = c.mark([element.text("marked")])
  assert element.to_string(result) == "<mark>marked</mark>"
}

pub fn default_u_produces_html_test() {
  let c = components.default()
  let result = c.u([element.text("underlined")])
  assert element.to_string(result) == "<u>underlined</u>"
}

pub fn default_span_produces_html_test() {
  let c = components.default()
  let result = c.span([element.text("content")])
  assert element.to_string(result) == "<span>content</span>"
}

pub fn default_hr_produces_html_test() {
  let c = components.default()
  let result = c.hr([])
  assert element.to_string(result) == "<hr>"
}

pub fn default_img_produces_html_test() {
  let c = components.default()
  let result = c.img([])
  assert element.to_string(result) == "<img>"
}

// --- Setter function tests ---

pub fn a_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.a(fn(children) {
      html.a([attribute.class("custom-link")], children)
    })
  let result = c.a([element.text("link")])
  assert element.to_string(result) == "<a class=\"custom-link\">link</a>"
}

pub fn blockquote_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.blockquote(fn(children) {
      html.blockquote([attribute.class("quote")], children)
    })
  let result = c.blockquote([element.text("text")])
  assert element.to_string(result)
    == "<blockquote class=\"quote\">text</blockquote>"
}

pub fn code_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.code(fn(children) {
      html.code([attribute.class("highlight")], children)
    })
  let result = c.code([element.text("x")])
  assert element.to_string(result) == "<code class=\"highlight\">x</code>"
}

pub fn del_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.del(fn(children) {
      html.del([attribute.class("removed")], children)
    })
  let result = c.del([element.text("old")])
  assert element.to_string(result) == "<del class=\"removed\">old</del>"
}

pub fn h1_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.h1(fn(children) {
      html.h1([attribute.class("title")], children)
    })
  let result = c.h1([element.text("heading")])
  assert element.to_string(result) == "<h1 class=\"title\">heading</h1>"
}

pub fn h2_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.h2(fn(children) {
      html.h2([attribute.class("subtitle")], children)
    })
  let result = c.h2([element.text("heading")])
  assert element.to_string(result) == "<h2 class=\"subtitle\">heading</h2>"
}

pub fn h3_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.h3(fn(children) { html.h3([attribute.class("h3")], children) })
  let result = c.h3([element.text("heading")])
  assert element.to_string(result) == "<h3 class=\"h3\">heading</h3>"
}

pub fn h4_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.h4(fn(children) { html.h4([attribute.class("h4")], children) })
  let result = c.h4([element.text("heading")])
  assert element.to_string(result) == "<h4 class=\"h4\">heading</h4>"
}

pub fn h5_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.h5(fn(children) { html.h5([attribute.class("h5")], children) })
  let result = c.h5([element.text("heading")])
  assert element.to_string(result) == "<h5 class=\"h5\">heading</h5>"
}

pub fn h6_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.h6(fn(children) { html.h6([attribute.class("h6")], children) })
  let result = c.h6([element.text("heading")])
  assert element.to_string(result) == "<h6 class=\"h6\">heading</h6>"
}

pub fn hr_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.hr(fn(_children) { html.hr([attribute.class("divider")]) })
  let result = c.hr([])
  assert element.to_string(result) == "<hr class=\"divider\">"
}

pub fn i_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.i(fn(children) {
      html.i([attribute.class("emphasis")], children)
    })
  let result = c.i([element.text("text")])
  assert element.to_string(result) == "<i class=\"emphasis\">text</i>"
}

pub fn img_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.img(fn(_children) { html.img([attribute.class("image")]) })
  let result = c.img([])
  assert element.to_string(result) == "<img class=\"image\">"
}

pub fn li_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.li(fn(children) {
      html.li([attribute.class("list-item")], children)
    })
  let result = c.li([element.text("item")])
  assert element.to_string(result) == "<li class=\"list-item\">item</li>"
}

pub fn mark_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.mark(fn(children) {
      html.mark([attribute.class("hl")], children)
    })
  let result = c.mark([element.text("text")])
  assert element.to_string(result) == "<mark class=\"hl\">text</mark>"
}

pub fn ol_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.ol(fn(children) {
      html.ol([attribute.class("ordered")], children)
    })
  let result = c.ol([element.text("items")])
  assert element.to_string(result) == "<ol class=\"ordered\">items</ol>"
}

pub fn p_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.p(fn(children) { html.p([attribute.class("body")], children) })
  let result = c.p([element.text("text")])
  assert element.to_string(result) == "<p class=\"body\">text</p>"
}

pub fn pre_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.pre(fn(children) {
      html.pre([attribute.class("code-block")], children)
    })
  let result = c.pre([element.text("code")])
  assert element.to_string(result) == "<pre class=\"code-block\">code</pre>"
}

pub fn span_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.span(fn(children) {
      html.span([attribute.class("inline")], children)
    })
  let result = c.span([element.text("text")])
  assert element.to_string(result) == "<span class=\"inline\">text</span>"
}

pub fn strong_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.strong(fn(children) {
      html.strong([attribute.class("bold")], children)
    })
  let result = c.strong([element.text("text")])
  assert element.to_string(result) == "<strong class=\"bold\">text</strong>"
}

pub fn table_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.table(fn(children) {
      html.table([attribute.class("data")], children)
    })
  let result = c.table([element.text("content")])
  assert element.to_string(result) == "<table class=\"data\">content</table>"
}

pub fn td_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.td(fn(children) {
      html.td([attribute.class("cell")], children)
    })
  let result = c.td([element.text("data")])
  assert element.to_string(result) == "<td class=\"cell\">data</td>"
}

pub fn th_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.th(fn(children) {
      html.th([attribute.class("header")], children)
    })
  let result = c.th([element.text("col")])
  assert element.to_string(result) == "<th class=\"header\">col</th>"
}

pub fn tr_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.tr(fn(children) {
      html.tr([attribute.class("row")], children)
    })
  let result = c.tr([element.text("cells")])
  assert element.to_string(result) == "<tr class=\"row\">cells</tr>"
}

pub fn u_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.u(fn(children) {
      html.u([attribute.class("underline")], children)
    })
  let result = c.u([element.text("text")])
  assert element.to_string(result) == "<u class=\"underline\">text</u>"
}

pub fn ul_setter_overrides_default_test() {
  let c =
    components.default()
    |> components.ul(fn(children) {
      html.ul([attribute.class("list")], children)
    })
  let result = c.ul([element.text("items")])
  assert element.to_string(result) == "<ul class=\"list\">items</ul>"
}

// --- Chained setter tests ---

pub fn chained_setters_override_multiple_components_test() {
  let c =
    components.default()
    |> components.h1(fn(children) {
      html.h1([attribute.class("heading")], children)
    })
    |> components.p(fn(children) {
      html.p([attribute.class("paragraph")], children)
    })
    |> components.strong(fn(children) {
      html.strong([attribute.class("bold")], children)
    })

  let h1_result = c.h1([element.text("title")])
  assert element.to_string(h1_result) == "<h1 class=\"heading\">title</h1>"

  let p_result = c.p([element.text("text")])
  assert element.to_string(p_result) == "<p class=\"paragraph\">text</p>"

  let strong_result = c.strong([element.text("bold")])
  assert element.to_string(strong_result)
    == "<strong class=\"bold\">bold</strong>"
}

pub fn setter_does_not_affect_other_components_test() {
  let c =
    components.default()
    |> components.h1(fn(children) {
      html.h1([attribute.class("custom")], children)
    })

  // h1 is customized
  let h1_result = c.h1([element.text("heading")])
  assert element.to_string(h1_result) == "<h1 class=\"custom\">heading</h1>"

  // h2 remains default
  let h2_result = c.h2([element.text("heading")])
  assert element.to_string(h2_result) == "<h2>heading</h2>"
}

// --- Component with custom element type test ---

pub fn setter_allows_different_element_type_test() {
  let c =
    components.default()
    |> components.p(fn(children) {
      // Use a <div> instead of <p>
      html.div([], children)
    })
  let result = c.p([element.text("content")])
  assert element.to_string(result) == "<div>content</div>"
}
