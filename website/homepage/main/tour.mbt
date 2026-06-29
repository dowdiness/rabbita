// ─── Types ────────────────────────────────────────────────────────────────

///|
pub(all) struct TourModel {
  chapter_idx : Int
  content : String
  failed : Bool
}

///|
pub let init_tour : TourModel = { chapter_idx: 0, content: "", failed: false }

///|
struct TocEntry {
  level : Int
  text : String
  id : String
}

///|
pub(all) struct TourChapter {
  title : String
  path : String // e.g. "001_intro" — used as URL slug and to locate doc files
  section : String // section name for sidebar grouping
} derive(FromJson)

// ─── Tour Chapters (default fallback) ────────────────────────────────────

///|
let tour_chapters : Array[TourChapter] = [
  { title: "Introduction", path: "001_intro", section: "Rabbita Basic" },
  { title: "Router", path: "003_router", section: "Rabbita Basic" },
]

// Returns the site root URL, e.g. "/" or "/rabbita/"

///|
extern "js" fn site_base_url() -> String =
  #| () => {
  #|   const moduleUrl = import.meta.url
  #|   return new URL("./", moduleUrl).pathname
  #| }

// Returns the base URL for tour pages, e.g. "/tour/" or "/rabbita/tour/"

///|
extern "js" fn tour_base_url() -> String =
  #| () => {
  #|   const moduleUrl = import.meta.url
  #|   return new URL("tour/", new URL("./", moduleUrl)).pathname
  #| }

///|
fn playground_url() -> String {
  site_base_url() + "playground/"
}

///|
fn scroll_to_heading(id : String) -> @rabbita.Cmd {
  @nav.scroll_to(id)
}

// Returns the doc directory URL base for a chapter

///|
fn chapter_base_url(ch : TourChapter) -> String {
  site_base_url() + "doc/" + ch.path + "/"
}

// Strips the site base prefix from a url.path (which has no leading slash).
// e.g. site_base_url()="/rabbita/" → strips "rabbita/" prefix
// e.g. site_base_url()="/"        → returns path unchanged

///|
fn strip_base(path : String) -> String {
  let base = site_base_url() // e.g. "/rabbita/" or "/"
  // strip_len = length of prefix to remove (base minus its leading "/")
  let strip_len = base.length() - 1
  if strip_len <= 0 || !("/" + path).has_prefix(base) {
    return path
  }
  let buf = StringBuilder::new()
  let mut i = 0
  for c in path.iter() {
    if i >= strip_len {
      buf.write_char(c)
    }
    i = i + 1
  }
  buf.to_string()
}

// Returns true for any path that maps to the tour section

///|
fn is_tour_url(chapters : Array[TourChapter], path : String) -> Bool {
  let p = strip_base(path)
  if p == "tour" || p == "tour/" || p.has_prefix("tour/") {
    return true
  }
  for ch in chapters {
    if p.has_suffix("/tour/" + ch.path) {
      return true
    }
  }
  false
}

// Finds the chapter index matching a URL path; defaults to 0

///|
fn chapter_idx_from_path(chapters : Array[TourChapter], path : String) -> Int {
  let p = strip_base(path)
  for i = 0; i < chapters.length(); i = i + 1 {
    let cp = chapters[i].path
    if p == "tour/" + cp || p.has_suffix("/tour/" + cp) {
      return i
    }
  }
  0
}

// ─── Menu / Chapter Fetch ─────────────────────────────────────────────────

// ─── Markdown Helpers ─────────────────────────────────────────────────────

///|
fn inline_to_text(inline : @cmark.Inline) -> String {
  let buf = StringBuilder::new()
  let stack : Array[@cmark.Inline] = [inline]
  for ;; {
    guard stack.pop() is Some(curr) else { break }
    match curr {
      Text({ v, .. }) => buf.write_string(v)
      Inlines({ v: is_, .. }) => {
        let arr = is_.to_array()
        for i = arr.length() - 1; i >= 0; i = i - 1 {
          stack.push(arr[i])
        }
      }
      Emphasis({ v: { inline: il, .. }, .. }) => stack.push(il)
      StrongEmphasis({ v: { inline: il, .. }, .. }) => stack.push(il)
      Link({ v: { text, .. }, .. }) => stack.push(text)
      Image({ v: { text, .. }, .. }) => stack.push(text)
      CodeSpan({ v: cs, .. }) => buf.write_string(cs.code())
      Break(_) => buf.write_char(' ')
      _ => ()
    }
  }
  buf.to_string()
}

///|
fn extract_toc(src : String) -> Array[TocEntry] {
  let doc = @cmark.Doc::from_string(heading_auto_ids=true, strict=false, src)
  let toc : Array[TocEntry] = []
  let stack : Array[@cmark.Block] = [doc.block]
  for ;; {
    guard stack.pop() is Some(b) else { break }
    match b {
      Heading({ v: { level, inline, id, .. }, .. }) => {
        let s = match id {
          Some(Auto(s)) => s
          Some(Id(s)) => s
          None => ""
        }
        if level >= 2 && level <= 3 && !s.is_empty() {
          toc.push({ level, text: inline_to_text(inline), id: s })
        }
      }
      Blocks({ v: bs, .. }) => {
        let arr = bs.to_array()
        for i = arr.length() - 1; i >= 0; i = i - 1 {
          stack.push(arr[i])
        }
      }
      BlockQuote({ v: { block: inner, .. }, .. }) => stack.push(inner)
      List({ v: { items, .. }, .. }) =>
        for item in items.iter() {
          stack.push(item.v.block)
        }
      _ => ()
    }
  }
  toc
}

// ─── Markdown Rendering ───────────────────────────────────────────────────

///|
fn render_link(
  defs : Map[String, @cmark.LabelDef],
  lnk : @cmark.InlineLink,
  is_image : Bool,
  base_url : String,
) -> Html {
  let dest = match lnk.reference {
    Inline({ v: ld, .. }) =>
      match ld.dest {
        Some({ v, .. }) => v
        None => ""
      }
    Ref(_, label, _) =>
      match defs.get(label.key) {
        Some(LinkDef({ v: ld, .. })) =>
          match ld.dest {
            Some({ v, .. }) => v
            None => ""
          }
        _ => ""
      }
  }
  if is_image {
    let src = if !(dest.has_prefix("http://") ||
      dest.has_prefix("https://") ||
      dest.has_prefix("/")) {
      base_url + dest
    } else {
      dest
    }
    img(class="md-img", src~, alt=inline_to_text(lnk.text))
  } else {
    a(class="md-link", href=dest, [render_inline(defs, lnk.text, base_url)])
  }
}

///|
fn render_inline(
  defs : Map[String, @cmark.LabelDef],
  inline : @cmark.Inline,
  base_url : String,
) -> Html {
  match inline {
    Text({ v, .. }) => text(v)
    Inlines({ v: is_, .. }) => {
      let children : Array[Html] = []
      for i in is_.iter() {
        children.push(render_inline(defs, i, base_url))
      }
      fragment(children)
    }
    Emphasis({ v: { inline: il, .. }, .. }) =>
      em([render_inline(defs, il, base_url)])
    StrongEmphasis({ v: { inline: il, .. }, .. }) =>
      strong([render_inline(defs, il, base_url)])
    CodeSpan({ v: cs, .. }) => code(cs.code())
    Link({ v: lnk, .. }) => render_link(defs, lnk, false, base_url)
    Image({ v: lnk, .. }) => render_link(defs, lnk, true, base_url)
    Break({ v: { ty: Hard, .. }, .. }) => @html.br()
    Break({ v: { ty: Soft, .. }, .. }) => text(" ")
    Autolink({ v: { link, .. }, .. }) => a(class="md-link", href=link.v, link.v)
    ExtStrikethrough({ v: st, .. }) =>
      del([render_inline(defs, st.0, base_url)])
    ExtMathSpan({ v: ms, .. }) => code(ms.tex())
    _ => nothing
  }
}

///|
fn render_code_block(hl : @shiki.Highlighter?, cb : @cmark.CodeBlock) -> Html {
  let lang = match cb.info_string {
    Some({ v, .. }) =>
      match @cmark.CodeBlock::language_of_info_string(v) {
        Some((l, _)) => l
        None => ""
      }
    None => ""
  }
  let code_src = {
    let lines : Array[String] = []
    for n in cb.code.iter() {
      lines.push(n.v)
    }
    while lines.length() > 0 && lines[lines.length() - 1] == "" {
      ignore(lines.pop())
    }
    let buf = StringBuilder::new()
    for i = 0; i < lines.length(); i = i + 1 {
      if i > 0 {
        buf.write_char('\n')
      }
      buf.write_string(lines[i])
    }
    buf.to_string()
  }
  match hl {
    Some(h) =>
      div(class="code-dual", [
        div(class="code-light", [
          h.code_to_html(code_src, lang~, theme="github-light"),
        ]),
        div(class="code-dark", [
          h.code_to_html(code_src, lang~, theme="github-dark-default"),
        ]),
      ])
    None => pre(class="md-pre", [code(code_src)])
  }
}

///|
fn render_table(
  defs : Map[String, @cmark.LabelDef],
  tbl : @cmark.Table,
  base_url : String,
) -> Html {
  let header_rows : Array[Html] = []
  let body_rows : Array[Html] = []
  for item in tbl.rows.iter() {
    let (row_node, _blanks) = item
    match row_node.v {
      Header(cells) => {
        let ths : Array[Html] = []
        for cell in cells.iter() {
          let (inline, _layout) = cell
          ths.push(th(class="md-th", [render_inline(defs, inline, base_url)]))
        }
        header_rows.push(tr(class="md-tr", ths))
      }
      Sep(_) => ()
      Data(cells) => {
        let tds : Array[Html] = []
        for cell in cells.iter() {
          let (inline, _layout) = cell
          tds.push(td(class="md-td", [render_inline(defs, inline, base_url)]))
        }
        body_rows.push(tr(class="md-tr", tds))
      }
    }
  }
  table(class="md-table", [
    thead(class="md-thead", header_rows),
    tbody(class="md-tbody", body_rows),
  ])
}

///|
fn render_block(
  hl : @shiki.Highlighter?,
  defs : Map[String, @cmark.LabelDef],
  block : @cmark.Block,
  base_url : String,
) -> Html {
  match block {
    Heading({ v: { level, inline, id, .. }, .. }) => {
      let id_str = match id {
        Some(Auto(s)) => s
        Some(Id(s)) => s
        None => ""
      }
      let attrs = if id_str.is_empty() {
        @html.Attrs::build()
      } else {
        @html.Attrs::build().id(id_str)
      }
      let content = [render_inline(defs, inline, base_url)]
      match level {
        1 => h1(class="md-h1", attrs~, content)
        2 => h2(class="md-h2", attrs~, content)
        3 => h3(class="md-h3", attrs~, content)
        4 => h4(class="md-h4", attrs~, content)
        5 => h5(class="md-h5", attrs~, content)
        _ => h6(class="md-h6", attrs~, content)
      }
    }
    Paragraph({ v: { inline, .. }, .. }) =>
      p(class="md-p", [render_inline(defs, inline, base_url)])
    CodeBlock({ v: cb, .. }) => render_code_block(hl, cb)
    ExtMathBlock({ v: cb, .. }) => render_code_block(hl, cb)
    BlockQuote({ v: { block: inner, .. }, .. }) =>
      blockquote(class="md-blockquote", [
        render_block(hl, defs, inner, base_url),
      ])
    List({ v: { ty, items, .. }, .. }) => {
      let list_items : Array[Html] = []
      for item in items.iter() {
        let li_inner = render_block(hl, defs, item.v.block, base_url)
        list_items.push(li(class="md-li", [li_inner]))
      }
      match ty {
        Unordered(_) => ul(class="md-ul", list_items)
        Ordered(start, _) => ol(class="md-ol", start~, list_items)
      }
    }
    Blocks({ v: bs, .. }) => {
      let children : Array[Html] = []
      for b in bs.iter() {
        children.push(render_block(hl, defs, b, base_url))
      }
      fragment(children)
    }
    ThematicBreak(_) => hr(class="md-hr")
    ExtTable({ v: tbl, .. }) => render_table(defs, tbl, base_url)
    BlankLine(_)
    | HtmlBlock(_)
    | LinkRefDefinition(_)
    | ExtFootnoteDefinition(_) => nothing
  }
}

///|
fn render_markdown(
  hl : @shiki.Highlighter?,
  src : String,
  base_url : String,
) -> Html {
  let doc = @cmark.Doc::from_string(heading_auto_ids=true, strict=false, src)
  render_block(hl, doc.defs, doc.block, base_url)
}

// ─── Tour View ────────────────────────────────────────────────────────────

///|
fn view_tour_sidebar(
  emit : Emit[Msg],
  tm : TourModel,
  chapters : Array[TourChapter],
) -> Html {
  let elements : Array[Html] = []
  let mut current_section = ""
  let mut current_items : Array[Html] = []
  for i = 0; i < chapters.length(); i = i + 1 {
    let ch = chapters[i]
    if ch.section != current_section {
      if !current_items.is_empty() {
        elements.push(ul(class="tour-chapter-list", current_items))
      }
      current_section = ch.section
      current_items = []
      if !ch.section.is_empty() {
        elements.push(p(class="tour-section-heading", ch.section))
      }
    }
    let cls = if i == tm.chapter_idx {
      "tour-chapter-item tour-chapter-item--active"
    } else {
      "tour-chapter-item"
    }
    current_items.push(
      li(class="tour-chapter-li", [
        button(class=cls, on_click=emit(SelectChapter(i)), ch.title),
      ]),
    )
  }
  if !current_items.is_empty() {
    elements.push(ul(class="tour-chapter-list", current_items))
  }
  div(class="tour-sidebar-left", [fragment(elements)])
}

///|
fn view_tour_toc(toc : Array[TocEntry], base_url : String) -> Html {
  if toc.is_empty() {
    div(class="tour-sidebar-right", nothing)
  } else {
    let items = toc.map(fn(entry) {
      let cls = "tour-toc-item tour-toc-item--h\{entry.level}"
      li(class=cls, [
        a(class="tour-toc-link", href=base_url + "#\{entry.id}", entry.text),
      ])
    })
    div(class="tour-sidebar-right", [
      p(class="tour-toc-heading", "On this page"),
      ul(class="tour-toc-list", items),
    ])
  }
}

///|
fn view_tour(emit : Emit[Msg], model : Model, tm : TourModel) -> Html {
  let chapters = model.chapters
  let chapter_idx = if tm.chapter_idx < chapters.length() {
    tm.chapter_idx
  } else {
    0
  }
  let base_url = if chapters.is_empty() {
    ""
  } else {
    chapter_base_url(chapters[chapter_idx])
  }
  let tour_url = if chapters.is_empty() {
    tour_base_url()
  } else {
    tour_base_url() + chapters[chapter_idx].path
  }
  let toc = if tm.content.is_empty() { [] } else { extract_toc(tm.content) }
  div(class="tour-main", [
    div(class="tour-layout", [
      view_tour_sidebar(emit, tm, chapters),
      div(class="tour-content", [
        div(class="md-body", [
          if tm.failed {
            div(class="tour-not-found", [
              p(class="tour-not-found-code", "404"),
              p(class="md-p", "Page not found."),
            ])
          } else if tm.content.is_empty() {
            p(class="md-p", "Loading…")
          } else {
            render_markdown(model.highlighter, tm.content, base_url)
          },
        ]),
      ]),
      view_tour_toc(toc, tour_url),
    ]),
  ])
}
