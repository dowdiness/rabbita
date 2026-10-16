///|
const SonnerRichColorCss : String =
  #|[data-slot="sonner"] [data-slot="toast"][data-variant="success"] {
  #|  border-color:var(--rui-sonner-success-border,light-dark(oklch(0.72 0.17 142 / 0.45),oklch(0.55 0.13 142 / 0.55))) !important;
  #|  background:var(--rui-sonner-success-background,light-dark(oklch(0.97 0.04 142),oklch(0.24 0.05 142))) !important;
  #|  color:var(--rui-sonner-success-foreground,light-dark(oklch(0.38 0.12 142),oklch(0.79 0.17 142))) !important;
  #|}
  #|[data-slot="sonner"] [data-slot="toast"][data-variant="destructive"] {
  #|  border-color:var(--rui-sonner-error-border,color-mix(in oklch,var(--rui-destructive,oklch(0.577 0.245 27.325)) 35%,transparent)) !important;
  #|  background:var(--rui-sonner-error-background,color-mix(in oklch,var(--rui-destructive,oklch(0.577 0.245 27.325)) 12%,var(--rui-background,oklch(1 0 0)))) !important;
  #|  color:var(--rui-sonner-error-foreground,var(--rui-destructive,oklch(0.577 0.245 27.325))) !important;
  #|}
  #|

///|
#warnings("-alert_xss_vulnerable")
fn sonner_rich_color_stylesheet() -> @html.Html {
  // Static selectors bridge Sonner's inline toast recipe to color-scheme-aware
  // rich-color tokens without requiring a consumer stylesheet.
  let attrs = @html.Attrs::build()
    .data_set("rui-style", "sonner-rich-colors")
    .inner_html(SonnerRichColorCss)
  @html.style_tag(attrs~, ([] : Array[@html.Html]))
}

///|
/// Stateful rich-color toast host matching shadcn's Sonner surface while using
/// Rabbita incremental state instead of a global JavaScript singleton.
pub fn sonner(
  max_toasts? : Int = 3,
  position? : String = "bottom-right",
  class? : String,
  attrs? : @html.Attrs,
  style? : Array[String] = [],
  on_focus_return? : () -> @cmd.Cmd,
  children : (ToastScope) -> @html.Html,
) -> @rabbita.Val[@html.Html] {
  toaster_impl(
    "sonner",
    true,
    max_toasts,
    position,
    class,
    attrs,
    style,
    on_focus_return,
    scope => @html.fragment([sonner_rich_color_stylesheet(), children(scope)]),
  )
}

///|
/// Compose application content and notifications once with a stable scope.
/// `build` returns incremental content and the application's focus policy.
/// Construct application state in `build`, never in a rendering callback.
pub fn sonner_host(
  max_toasts? : Int = 3,
  position? : String = "bottom-right",
  class? : String,
  attrs? : @html.Attrs,
  style? : Array[String] = [],
  build~ : (ToastScope) -> (@rabbita.Val[@html.Html], () -> @cmd.Cmd),
) -> @rabbita.Val[@html.Html] {
  let (notifications, content) = toaster_state(
    "sonner",
    true,
    max_toasts,
    position,
    class,
    attrs,
    style,
    scope => {
      let (content, policy) = build(scope)
      (content, Some(policy))
    },
    _ => sonner_rich_color_stylesheet(),
  )
  content.map2(notifications, (content, notifications) => {
    @html.fragment([content, notifications])
  })
}
