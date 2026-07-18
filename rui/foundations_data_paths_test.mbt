///|
#warnings("-alert_unstable")
fn audit_render(html : @html.Html) -> String {
  @rabbita.render_to_string(() => @rabbita.Val::constant(html))
}

///|
fn audit_contains(actual : String, expected : String) -> Unit raise {
  if !actual.contains(expected) {
    fail("expected rendered HTML to contain `\{expected}`; got `\{actual}`")
  }
}

///|
fn audit_not_contains(actual : String, unexpected : String) -> Unit raise {
  if actual.contains(unexpected) {
    fail(
      "expected rendered HTML not to contain `\{unexpected}`; got `\{actual}`",
    )
  }
}

///|
fn audit_test_icon(path : String) -> @html.Html {
  @html.span(
    attrs=@html.Attrs::build().aria_hidden("true"),
    @svg.svg(width=16, height=16, view_box="0 0 24 24", [
      @svg.path(
        d=path,
        fill="none",
        stroke="currentColor",
        stroke_width=2,
        attrs=@svg.Attrs::build()
          .stroke_linecap("round")
          .stroke_linejoin("round"),
      ),
    ]),
  )
}

///|
test "native as-child link paths retain semantics and disabled state" {
  let html = audit_render(
    @html.div([
      @rui.badge_link(
        href="/status",
        variant=@rui.Outline,
        disabled=true,
        aria_label="Unavailable status",
        "Status",
      ),
      @rui.item_link(
        href="/workspace",
        variant=@rui.ItemMuted,
        size=@rui.ItemSm,
        disabled=true,
        aria_label="Unavailable workspace",
        @rui.item_content([
          @rui.item_title("Workspace"),
          @rui.item_description(
            "A deliberately long description that exercises wrapping and the two-line clamp.",
          ),
        ]),
      ),
      @rui.attachment(
        @rui.attachment_trigger_link(
          href="/files/specification",
          disabled=true,
          aria_label="Unavailable specification",
          "Open",
        ),
      ),
      @rui.bubble(
        variant=@rui.BubbleSecondary,
        @rui.bubble_content_link(
          href="/reply",
          disabled=true,
          aria_label="Unavailable reply",
          "Reply",
        ),
      ),
      @rui.marker_link(
        href="/activity",
        variant=@rui.MarkerSeparator,
        disabled=true,
        aria_label="Unavailable activity",
        @rui.marker_content("Activity"),
      ),
    ]),
  )
  audit_contains(html, "<a")
  audit_contains(html, "href=\"/status\"")
  audit_contains(html, "href=\"/workspace\"")
  audit_contains(html, "href=\"/files/specification\"")
  audit_contains(html, "href=\"/reply\"")
  audit_contains(html, "href=\"/activity\"")
  audit_contains(html, "aria-disabled=\"true\"")
  audit_contains(html, "tabindex=\"-1\"")
  audit_contains(html, "data-disabled=\"\"")
  audit_contains(html, "data-slot=\"badge\" data-variant=\"outline\"")
  audit_contains(
    html, "data-slot=\"item\" data-variant=\"muted\" data-size=\"sm\"",
  )
  audit_contains(html, "data-slot=\"attachment-trigger\"")
  audit_contains(html, "data-slot=\"bubble-content\"")
  audit_contains(html, "data-slot=\"marker\" data-variant=\"separator\"")
  audit_contains(html, "cursor:not-allowed;pointer-events:none;opacity:0.5")
}

///|
test "interactive bubble button follows parent variant and native button state" {
  let html = audit_render(
    @rui.bubble(
      variant=@rui.BubbleDestructive,
      align=@rui.AlignEnd,
      @rui.bubble_content_button(
        disabled=true,
        aria_label="Retry unavailable",
        "Retry",
      ),
    ),
  )
  audit_contains(html, "data-slot=\"bubble\"")
  audit_contains(html, "data-variant=\"destructive\"")
  audit_contains(html, "data-align=\"end\"")
  audit_contains(html, "--rui-bubble-bg:var(--rui-destructive-subtle")
  audit_contains(html, "<button")
  audit_contains(html, "type=\"button\"")
  audit_contains(html, "disabled")
  audit_contains(html, "aria-disabled=\"true\"")
  audit_contains(
    html, "background:var(--rui-bubble-bg,var(--rui-primary,oklch(0.205 0 0)))",
  )

  let standalone = audit_render(
    @rui.bubble_content_button(aria_label="Retry", "Retry"),
  )
  audit_not_contains(standalone, "--rui-bubble-bg:")
  audit_not_contains(standalone, "--rui-bubble-border:")
}

///|
test "message and bubble recipes cover Vega variants alignment and reactions" {
  let html = audit_render(
    @rui.message(
      align=@rui.AlignEnd,
      @rui.message_content([
        @rui.message_header(
          "A long sender label that must stay inside a narrow message row",
        ),
        @rui.bubble_group([
          @rui.bubble(
            @rui.bubble_content(
              "abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz",
            ),
          ),
          @rui.bubble(
            variant=@rui.BubbleSecondary,
            @rui.bubble_content("Secondary"),
          ),
          @rui.bubble(variant=@rui.BubbleMuted, @rui.bubble_content("Muted")),
          @rui.bubble(variant=@rui.BubbleTinted, @rui.bubble_content("Tinted")),
          @rui.bubble(
            variant=@rui.BubbleOutline,
            @rui.bubble_content("Outline"),
          ),
          @rui.bubble(variant=@rui.BubbleGhost, @rui.bubble_content("Ghost")),
          @rui.bubble(variant=@rui.BubbleDestructive, align=@rui.AlignEnd, [
            @rui.bubble_content("Destructive"),
            @rui.bubble_reactions(
              side=@rui.ReactionTop,
              align=@rui.AlignStart,
              audit_test_icon("M20 6 9 17l-5-5"),
            ),
            @rui.bubble_reactions(
              side=@rui.ReactionBottom,
              align=@rui.AlignEnd,
              @html.span("2"),
            ),
          ]),
        ]),
        @rui.message_footer("Delivered"),
      ]),
    ),
  )
  audit_contains(html, "--rui-message-content-align:flex-end")
  audit_contains(html, "align-self:var(--rui-message-content-align,flex-start)")
  audit_contains(html, "overflow-wrap:break-word;word-break:normal")
  audit_contains(html, "data-variant=\"default\"")
  audit_contains(html, "data-variant=\"secondary\"")
  audit_contains(html, "data-variant=\"muted\"")
  audit_contains(html, "data-variant=\"tinted\"")
  audit_contains(html, "data-variant=\"outline\"")
  audit_contains(html, "data-variant=\"ghost\"")
  audit_contains(html, "data-variant=\"destructive\"")
  audit_contains(html, "max-width:100%")
  audit_contains(html, "light-dark(oklch(from var(--rui-primary")
  audit_contains(html, "--rui-bubble-content-align:flex-end")
  audit_contains(html, "data-side=\"top\" data-align=\"start\"")
  audit_contains(html, "top:0;inset-inline-start:0.75rem")
  audit_contains(html, "data-side=\"bottom\" data-align=\"end\"")
  audit_contains(html, "bottom:0;inset-inline-end:0.75rem")

  let avatar = audit_render(@rui.message_avatar("Y"))
  audit_contains(avatar, "min-height:2rem;aspect-ratio:1")
  let themed = audit_render(@rui.theme(@html.nothing))
  audit_contains(themed, "[data-slot=\"bubble-reactions\"]:has(button)")
  audit_contains(
    themed, ":is(a,button)[data-slot=\"bubble-content\"]:not(:disabled):not([aria-disabled=\"true\"]):active",
  )
  audit_contains(
    themed, "color-mix(in oklch,var(--rui-secondary,oklch(0.97 0 0)) 95%,var(--rui-foreground",
  )
}

///|
test "button and button-group children expose per-edge merge variables" {
  let html = audit_render(
    @rui.button_group([
      @rui.button(
        size=@rui.IconXs,
        attrs=@html.Attrs::build().aria_label("Previous item"),
        audit_test_icon("m15 18-6-6 6-6"),
      ),
      @rui.button_group_text("of 3"),
      @rui.button(size=@rui.Lg, "Next"),
    ]),
  )
  audit_contains(html, "data-slot=\"button-group\"")
  audit_contains(
    html, "border-top-width:var(--rui-control-border-top-width,var(--rui-control-border-width,1px))",
  )
  audit_contains(
    html, "border-left-width:var(--rui-control-border-left-width,var(--rui-control-border-width,1px))",
  )
  audit_contains(
    html, "border-top-left-radius:var(--rui-control-radius-top-left,var(--rui-control-radius",
  )
  audit_contains(
    html, "border-bottom-right-radius:var(--rui-control-radius-bottom-right,var(--rui-control-radius",
  )
  audit_contains(html, "--rui-button-icon-size:0.75rem")
  audit_contains(html, "--rui-button-padding-inline:1.5rem")

  let themed = audit_render(@rui.theme(@html.nothing))
  audit_contains(
    themed, "[data-slot=\"button-group\"][data-orientation=\"horizontal\"]:dir(ltr) > :has(+ [data-slot=\"button-group-separator\"][data-orientation=\"vertical\"]) {\n    --rui-control-border-right-width:0px",
  )
  audit_contains(
    themed, "[data-slot=\"button-group\"][data-orientation=\"horizontal\"]:dir(rtl) > :has(+ [data-slot=\"button-group-separator\"][data-orientation=\"vertical\"]) {\n    --rui-control-border-left-width:0px",
  )
  audit_contains(
    themed, "[data-slot=\"button-group\"][data-orientation=\"vertical\"] > :has(+ [data-slot=\"button-group-separator\"][data-orientation=\"horizontal\"]) {\n    --rui-control-border-bottom-width:0px",
  )
}

///|
test "separator, spinner, and skeleton cover semantic and motion branches" {
  let invalid_ratio = audit_render(@rui.aspect_ratio(ratio=0.0, "Preview"))
  audit_contains(invalid_ratio, "aspect-ratio:1")

  let decorative = audit_render(@rui.separator())
  audit_contains(decorative, "role=\"none\"")
  audit_not_contains(decorative, "aria-orientation")

  let semantic = audit_render(
    @rui.separator(orientation=@rui.Vertical, decorative=false),
  )
  audit_contains(semantic, "role=\"separator\"")
  audit_contains(semantic, "aria-orientation=\"vertical\"")

  let spinner_html = audit_render(@rui.spinner(label="Loading data"))
  audit_contains(spinner_html, "role=\"status\"")
  audit_contains(spinner_html, "aria-label=\"Loading data\"")
  audit_contains(spinner_html, "width=\"16\"")
  audit_contains(spinner_html, "height=\"16\"")
  audit_contains(spinner_html, "viewBox=\"0 0 24 24\"")
  audit_contains(spinner_html, "animation:rui-spin 1s linear infinite")
  audit_contains(spinner_html, "M21 12a9 9 0 1 1-6.219-8.56")
  audit_not_contains(spinner_html, "<circle")
  audit_not_contains(spinner_html, "animateTransform")

  let skeleton_html = audit_render(@rui.skeleton())
  audit_contains(skeleton_html, "data-slot=\"skeleton\"")
  audit_contains(skeleton_html, "animation:rui-pulse 2s")
}

///|
test "attachment size orientation and state variables propagate to parts" {
  let html = audit_render(
    @html.div([
      @rui.attachment(
        state=@rui.AttachmentIdle,
        size=@rui.AttachmentXs,
        orientation=@rui.AttachmentHorizontal,
        @rui.attachment_media("File"),
      ),
      @rui.attachment(
        state=@rui.AttachmentError,
        size=@rui.AttachmentSm,
        orientation=@rui.AttachmentVertical,
        [
          @rui.attachment_media(variant=@rui.AttachmentImage, "Preview"),
          @rui.attachment_content(@rui.attachment_description("Upload failed")),
        ],
      ),
      @rui.attachment(
        state=@rui.AttachmentProcessing,
        @rui.attachment_content(@rui.attachment_title("Processing file")),
      ),
    ]),
  )
  audit_contains(html, "data-state=\"idle\"")
  audit_contains(html, "data-size=\"xs\"")
  audit_contains(html, "data-orientation=\"horizontal\"")
  audit_contains(html, "--rui-attachment-media-size:1.75rem")
  audit_contains(html, "border-style:dashed")
  audit_contains(html, "data-state=\"error\"")
  audit_contains(html, "data-size=\"sm\"")
  audit_contains(html, "data-orientation=\"vertical\"")
  audit_contains(html, "--rui-attachment-media-width:100%")
  audit_contains(html, "--rui-attachment-icon-size:1.5rem")
  audit_contains(html, "--rui-attachment-image-opacity:0.6")
  audit_contains(html, "--rui-attachment-description-fg:color-mix")
  audit_contains(
    html, "--rui-attachment-title-animation:rui-shimmer 2s linear infinite",
  )
  audit_contains(html, "--rui-attachment-title-shimmer-spread:calc(3ch + 40px)")
  audit_contains(
    html, "linear-gradient(calc(90deg + var(--rui-attachment-title-shimmer-angle,20deg))",
  )
  audit_contains(html, "--rui-attachment-title-text-fill:transparent")
  audit_contains(html, "animation:var(--rui-attachment-title-animation,none)")
  audit_contains(
    html, "-webkit-text-fill-color:var(--rui-attachment-title-text-fill,currentColor)",
  )
  audit_contains(
    html, "padding-block:var(--rui-attachment-padding-block,0);padding-inline:var(--rui-attachment-padding-inline,0)",
  )

  let themed = audit_render(@rui.theme(@html.nothing))
  audit_contains(
    themed, "[data-slot=\"attachment\"]:has(> [data-slot=\"attachment-content\"])",
  )
  audit_contains(
    themed, "--rui-attachment-padding-block:var(--rui-attachment-content-padding-block,0)",
  )
  audit_contains(
    themed, "[data-slot=\"attachment\"]:has(> [data-slot=\"attachment-media\"]):not(:has(> [data-slot=\"attachment-content\"]))",
  )

  let group = audit_render(
    @rui.attachment_group(
      @rui.attachment(
        @rui.attachment_trigger(aria_label="Open file", @html.nothing),
      ),
    ),
  )
  audit_contains(group, "box-sizing:border-box")
  audit_contains(group, "padding-inline:0.25rem")
  audit_contains(group, "scroll-padding-inline:0.25rem")
}

///|
test "alert and card optional tracks do not reserve empty columns" {
  let html = audit_render(
    @html.div([
      @rui.alert([
        @rui.alert_title("Notice"),
        @rui.alert_description("Description"),
      ]),
      @rui.card(
        @rui.card_header([
          @rui.card_title("Title"),
          @rui.card_description("Description"),
        ]),
      ),
    ]),
  )
  audit_contains(
    html, "grid-template-columns:var(--rui-alert-columns,0 minmax(0,1fr) auto)",
  )
  audit_contains(html, "column-gap:var(--rui-alert-column-gap,0)")
  audit_contains(
    html, "grid-template-columns:var(--rui-card-header-columns,minmax(0,1fr))",
  )
  audit_contains(html, "column-gap:var(--rui-card-header-column-gap,0)")

  let themed = audit_render(
    @rui.theme(
      @rui.alert(@svg.svg(view_box="0 0 24 24", [@svg.path(d="M12 2v20")])),
    ),
  )
  audit_contains(themed, "[data-slot=\"alert\"]:has(> svg)")
  audit_contains(themed, "--rui-alert-columns:auto minmax(0,1fr) auto")
  audit_contains(
    themed, "[data-slot=\"card-header\"]:has(> [data-slot=\"card-action\"])",
  )
  audit_contains(themed, "@keyframes rui-shimmer")
  audit_contains(themed, "from { background-position:100% 0; }")
  audit_contains(themed, "to { background-position:0 0; }")
  audit_contains(themed, "-webkit-text-fill-color:currentColor !important")
}

///|
test "logical-direction and long-content recipes remain narrow-safe" {
  let html = audit_render(
    @rui.direction(
      direction=@rui.Rtl,
      @html.div([
        @rui.item_link(
          href="/rtl",
          @rui.item_description(
            "A very long unbroken identifier abcdefghijklmnopqrstuvwxyz0123456789",
          ),
        ),
        @rui.message(align=@rui.AlignEnd, @rui.message_content("Message")),
        @rui.table(
          @rui.table_body(
            @rui.table_row(
              @rui.table_cell("A long cell that may need horizontal scroll"),
            ),
          ),
        ),
      ]),
    ),
  )
  audit_contains(html, "dir=\"rtl\"")
  audit_contains(html, "text-align:start")
  audit_contains(html, "min-width:0")
  audit_contains(html, "-webkit-line-clamp:2")
  audit_contains(html, "--rui-message-content-align:flex-end")
  audit_contains(html, "overflow-x:auto")
}
