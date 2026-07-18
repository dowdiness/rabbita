///|
test "typography wrappers keep their semantic elements and Vega recipes" {
  let html = render(
    @html.div([
      @rui.typography_h1("Heading one"),
      @rui.typography_h2("Heading two"),
      @rui.typography_h3("Heading three"),
      @rui.typography_h4("Heading four"),
      @rui.typography_p("Body copy"),
      @rui.typography_blockquote("Quoted copy"),
      @rui.typography_list([@html.li("First"), @html.li("Second")]),
      @rui.typography_inline_code("let answer = 42"),
      @rui.typography_lead("Lead copy"),
      @rui.typography_large("Large copy"),
      @rui.typography_small("Small copy"),
      @rui.typography_muted("Muted copy"),
    ]),
  )
  assert_contains(html, "<h1 data-slot=\"typography-h1\"")
  assert_contains(html, "<h2 data-slot=\"typography-h2\"")
  assert_contains(html, "<h3 data-slot=\"typography-h3\"")
  assert_contains(html, "<h4 data-slot=\"typography-h4\"")
  assert_contains(html, "<p data-slot=\"typography-p\"")
  assert_contains(html, "<blockquote data-slot=\"typography-blockquote\"")
  assert_contains(html, "<ul data-slot=\"typography-list\"")
  assert_contains(html, "<code data-slot=\"typography-inline-code\"")
  assert_contains(html, "<p data-slot=\"typography-lead\"")
  assert_contains(html, "<div data-slot=\"typography-large\"")
  assert_contains(html, "<small data-slot=\"typography-small\"")
  assert_contains(html, "<p data-slot=\"typography-muted\"")
  assert_contains(html, "font-size:2.25rem;line-height:2.5rem;font-weight:800")
  assert_contains(
    html, "border-bottom:1px solid var(--rui-border,oklch(0.922 0 0));padding-bottom:0.5rem",
  )
  assert_contains(html, "border-inline-start:2px solid var(--rui-border")
  assert_contains(html, "background:var(--rui-muted,oklch(0.97 0 0))")
  assert_contains(
    html, "color:var(--rui-muted-foreground,oklch(0.556 0 0));font-size:1.25rem",
  )
}

///|
test "typography appends caller styles and does not mutate caller attrs" {
  let attrs = @html.Attrs::build().data_set("owner", "caller")
  let html = render(
    @rui.typography_h2(
      attrs~,
      id="custom-heading",
      class="heading",
      hidden=true,
      style=["border-bottom:0", "color:rebeccapurple"],
      "Custom",
    ),
  )
  assert_contains(html, "data-owner=\"caller\"")
  assert_contains(html, "data-slot=\"typography-h2\"")
  assert_contains(html, "id=\"custom-heading\"")
  assert_contains(html, "class=\"heading\"")
  assert_contains(html, "hidden")
  assert_contains(
    html, "letter-spacing:-0.025em;border-bottom:0;color:rebeccapurple",
  )

  let original = render(@html.div(attrs~, @html.nothing))
  assert_contains(original, "data-owner=\"caller\"")
  assert_not_contains(original, "data-slot")
}
