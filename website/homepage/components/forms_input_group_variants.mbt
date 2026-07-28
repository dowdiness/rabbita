///|
fn forms_input_group_star_icon() -> @html.Html {
  showcase_stroke_icon(
    "m12 2 3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01Z",
  )
}

///|
fn forms_input_group_info_icon() -> @html.Html {
  showcase_stroke_icon("M12 16v-4M12 8h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0")
}

///|
fn forms_input_group_chevron_down_icon() -> @html.Html {
  showcase_stroke_icon("m6 9 6 6 6-6")
}

///|
const FormsInputGroupBasicCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-basic",
    #|      placeholder="Search...",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-basic",
    #|      stroke_icon("M21 21l-4.35-4.35M19 11a8 8 0 1 1-16 0 8 8 0 0 1 16 0"),
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineEnd,
    #|      for_="forms-variants-input-group-basic",
    #|      @rui.input_group_text("12 results"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupInlineStartCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-inline-start",
    #|      placeholder="Search...",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-inline-start",
    #|      stroke_icon("M21 21l-4.35-4.35M19 11a8 8 0 1 1-16 0 8 8 0 0 1 16 0"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupInlineEndCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      input_type=@html.Password,
    #|      id="forms-variants-input-group-inline-end",
    #|      placeholder="Enter password",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineEnd,
    #|      for_="forms-variants-input-group-inline-end",
    #|      stroke_icon("m2 2 20 20M6.71 6.71C4.9 8.02 3.5 9.76 3 12c1.2 5.4 7.2 8.2 12.4 5.5M10.73 5.08A10.9 10.9 0 0 1 12 5c5 0 8.5 3 9 7a11.1 11.1 0 0 1-2.1 4.2M14.12 14.12A3 3 0 0 1 9.88 9.88"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupBlockStartCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-block-start",
  #|      placeholder="Enter your name",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputBlockStart,
  #|      for_="forms-variants-input-group-block-start",
  #|      @rui.input_group_text("Full name"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupBlockStartTextareaCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,26rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_textarea(
    #|      id="forms-variants-input-group-block-start-textarea",
    #|      rows=5,
    #|      placeholder="println(\"Hello, world!\")",
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputBlockStart, [
    #|      @rui.input_group_text([
    #|        stroke_icon("M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6"),
    #|        @html.span("script.mbt"),
    #|      ]),
    #|      @rui.input_group_button(
    #|        size=@rui.InputButtonIconXs,
    #|        title="Copy script",
    #|        attrs=@html.Attrs::build().aria_label("Copy script"),
    #|        style=["margin-inline-start:auto"],
    #|        on_click=@clipboard.copy(@clipboard.Text("println(\"Hello, world!\")")),
    #|        stroke_icon("M8 8h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H10a2 2 0 0 1-2-2ZM4 16a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2"),
    #|      ),
    #|    ]),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupBlockEndCode : String =
  #|@html.div(
  #|  style=["width:min(100%,26rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_textarea(
  #|      id="forms-variants-input-group-block-end",
  #|      rows=4,
  #|      placeholder="Write a comment...",
  #|    ),
  #|    @rui.input_group_addon(align=@rui.InputBlockEnd, [
  #|      @rui.input_group_text(style=["flex:1"], "0/280"),
  #|      @rui.input_group_button(
  #|        size=@rui.InputButtonSm,
  #|        variant=@rui.Default,
  #|        "Post",
  #|      ),
  #|    ]),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupBlockEndInputCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-block-end-input",
  #|      placeholder="Enter amount",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputBlockEnd,
  #|      @rui.input_group_text("USD"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupIconSearchCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-icon-search",
    #|      placeholder="Search...",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-icon-search",
    #|      stroke_icon("M21 21l-4.35-4.35M19 11a8 8 0 1 1-16 0 8 8 0 0 1 16 0"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupIconEmailCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      input_type=@html.Email,
    #|      id="forms-variants-input-group-icon-email",
    #|      placeholder="Enter your email",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-icon-email",
    #|      stroke_icon("m22 7-8.991 5.727a2 2 0 0 1-2.009 0L2 7M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupIconsCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-icons",
    #|      placeholder="Card number",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-icons",
    #|      stroke_icon("M2 10h20M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"),
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineEnd,
    #|      for_="forms-variants-input-group-icons",
    #|      stroke_icon("M20 6 9 17l-5-5"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupIconMetadataCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-icon-metadata",
    #|      placeholder="Card number",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineEnd,
    #|      for_="forms-variants-input-group-icon-metadata",
    #|      [
    #|        stroke_icon("m12 2 3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01Z"),
    #|        stroke_icon("M12 16v-4M12 8h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0"),
    #|      ],
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupTextCurrencyCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-text-currency",
  #|      placeholder="0.00",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineStart,
  #|      for_="forms-variants-input-group-text-currency",
  #|      @rui.input_group_text("$"),
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineEnd,
  #|      for_="forms-variants-input-group-text-currency",
  #|      @rui.input_group_text("USD"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupTextCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-text",
  #|      placeholder="example",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineStart,
  #|      for_="forms-variants-input-group-text",
  #|      @rui.input_group_text("https://"),
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineEnd,
  #|      for_="forms-variants-input-group-text",
  #|      @rui.input_group_text(".com"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupTextUsernameCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-text-username",
  #|      placeholder="Enter your username",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineEnd,
  #|      for_="forms-variants-input-group-text-username",
  #|      @rui.input_group_text("@company.com"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupTextCountCode : String =
  #|@html.div(
  #|  style=["width:min(100%,26rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_textarea(
  #|      id="forms-variants-input-group-text-count",
  #|      rows=4,
  #|      placeholder="Enter your message",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputBlockEnd,
  #|      @rui.input_group_text("120 characters left"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupButtonsCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-button",
    #|      value="https://rabbit-tea.dev",
    #|      read_only=true,
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputInlineEnd, [
    #|      @rui.input_group_button(
    #|        size=@rui.InputButtonIconXs,
    #|        title="Copy URL",
    #|        attrs=@html.Attrs::build().aria_label("Copy URL"),
    #|        on_click=@clipboard.copy(@clipboard.Text("https://rabbit-tea.dev")),
    #|        stroke_icon("M8 8h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H10a2 2 0 0 1-2-2ZM4 16a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2"),
    #|      ),
    #|    ]),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupConnectionButtonsCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|let info = @rui.popover(
    #|  id="forms-variants-input-group-connection-info",
    #|  side=@rui.Bottom,
    #|  align=@rui.Start,
    #|  side_offset=8,
    #|  trigger_variant=@rui.Secondary,
    #|  trigger_size=@rui.IconXs,
    #|  trigger_attrs=@html.Attrs::build().aria_label("Connection information"),
    #|  trigger_style=["border-radius:9999px"],
    #|  stroke_icon("M12 16v-4M12 8h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0"),
    #|  @html.div(style=["display:flex;width:16rem;flex-direction:column;gap:0.25rem"], [
    #|    @html.strong("Your connection is not secure."),
    #|    @html.p(
    #|      style=["margin:0;color:var(--rui-muted-foreground);font-size:0.8125rem"],
    #|      "Do not enter sensitive information on this site.",
    #|    ),
    #|  ]),
    #|)
    #|let favorite = @rui.toggle(
    #|  id="forms-variants-input-group-favorite",
    #|  size=@rui.Sm,
    #|  aria_label="Favorite connection",
    #|  style=["width:1.5rem;height:1.5rem;min-width:1.5rem;padding:0;border-radius:9999px"],
    #|  stroke_icon("m12 2 3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01Z"),
    #|)
    #|info.view2(favorite, (info_html, favorite_html) => @html.div(
    #|  style=["width:min(100%,26rem);margin-inline:auto"],
    #|  @rui.input_group(style=["--rui-radius:9999px"], [
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-secure",
    #|      value="rabbit-tea.dev",
    #|      read_only=true,
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputInlineStart, info_html),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-secure",
    #|      @rui.input_group_text("https://"),
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputInlineEnd, favorite_html),
    #|  ]),
    #|))
    #|
  )

///|
const FormsInputGroupSearchButtonCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-search-button",
  #|      placeholder="Type to search...",
  #|    ),
  #|    @rui.input_group_addon(align=@rui.InputInlineEnd, [
  #|      @rui.input_group_button(
  #|        size=@rui.InputButtonXs,
  #|        variant=@rui.Secondary,
  #|        "Search",
  #|      ),
  #|    ]),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupKbdCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-kbd",
    #|      placeholder="Search...",
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineStart,
    #|      for_="forms-variants-input-group-kbd",
    #|      stroke_icon("M21 21l-4.35-4.35M19 11a8 8 0 1 1-16 0 8 8 0 0 1 16 0"),
    #|    ),
    #|    @rui.input_group_addon(
    #|      align=@rui.InputInlineEnd,
    #|      for_="forms-variants-input-group-kbd",
    #|      @rui.kbd("⌘K"),
    #|    ),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupDropdownCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|let menu = @rui.dropdown_menu(id="forms-variants-input-group-dropdown-menu", scope => {
    #|  @html.fragment([
    #|    @rui.dropdown_menu_trigger(
    #|      scope,
    #|      variant=@rui.Ghost,
    #|      size=@rui.IconXs,
    #|      aria_label="More file actions",
    #|      stroke_icon("M5 12h.01M12 12h.01M19 12h.01"),
    #|    ),
    #|    @rui.dropdown_menu_portal([
    #|      @rui.dropdown_menu_content(scope, align=@rui.End, side_offset=8, [
    #|        @rui.dropdown_menu_item(scope, "Settings"),
    #|        @rui.dropdown_menu_item(scope, "Copy path"),
    #|        @rui.dropdown_menu_item(scope, "Open location"),
    #|      ]),
    #|    ]),
    #|  ])
    #|})
    #|menu.view(menu_html => @html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-dropdown",
    #|      placeholder="Enter file name",
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputInlineEnd, menu_html),
    #|  ]),
    #|))
    #|
  )

///|
const FormsInputGroupDropdownQueryCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|let menu = @rui.dropdown_menu(id="forms-variants-input-group-query-menu", scope => {
    #|  @html.fragment([
    #|    @rui.dropdown_menu_trigger(
    #|      scope,
    #|      variant=@rui.Ghost,
    #|      size=@rui.Xs,
    #|      aria_label="Choose search scope",
    #|      style=["gap:0.25rem;padding-inline:0.375rem;font-size:0.75rem"],
    #|      [
    #|        @html.span("Search in"),
    #|        stroke_icon("m6 9 6 6 6-6"),
    #|      ],
    #|    ),
    #|    @rui.dropdown_menu_portal([
    #|      @rui.dropdown_menu_content(
    #|        scope,
    #|        align=@rui.End,
    #|        side_offset=8,
    #|        align_offset=-4,
    #|        [
    #|          @rui.dropdown_menu_item(scope, "Documentation"),
    #|          @rui.dropdown_menu_item(scope, "Blog posts"),
    #|          @rui.dropdown_menu_item(scope, "Changelog"),
    #|        ],
    #|      ),
    #|    ]),
    #|  ])
    #|})
    #|menu.view(menu_html => @html.div(
    #|  style=["width:min(100%,24rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_input(
    #|      id="forms-variants-input-group-query",
    #|      placeholder="Enter search query",
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputInlineEnd, menu_html),
    #|  ]),
    #|))
    #|
  )

///|
const FormsInputGroupSpinnerTrailingCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-spinner-trailing",
  #|      placeholder="Searching...",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineEnd,
  #|      @rui.spinner(label="Searching"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupSpinnerLeadingCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-spinner-leading",
  #|      placeholder="Processing...",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineStart,
  #|      @rui.spinner(label="Processing"),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupLoadingCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-loading",
  #|      placeholder="Saving changes...",
  #|    ),
  #|    @rui.input_group_addon(align=@rui.InputInlineEnd, [
  #|      @rui.input_group_text("Saving..."),
  #|      @rui.spinner(label="Saving changes"),
  #|    ]),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupSpinnerStatusCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_input(
  #|      id="forms-variants-input-group-spinner-status",
  #|      placeholder="Refreshing data...",
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineStart,
  #|      @rui.spinner(label="Refreshing data"),
  #|    ),
  #|    @rui.input_group_addon(
  #|      align=@rui.InputInlineEnd,
  #|      @rui.input_group_text("Please wait..."),
  #|    ),
  #|  ]),
  #|)
  #|

///|
const FormsInputGroupTextareaToolbarCode : String = FoundationsStrokeIconCode +
  (
    #|
    #|@html.div(
    #|  style=["width:min(100%,30rem);margin-inline:auto"],
    #|  @rui.input_group([
    #|    @rui.input_group_textarea(
    #|      id="forms-variants-input-group-editor",
    #|      rows=7,
    #|      placeholder="println(\"Hello, world!\")",
    #|    ),
    #|    @rui.input_group_addon(align=@rui.InputBlockStart, [
    #|      @rui.input_group_text([
    #|        stroke_icon("M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6"),
    #|        @html.span("main.mbt"),
    #|      ]),
    #|      @rui.input_group_button(
    #|        size=@rui.InputButtonIconXs,
    #|        title="Refresh",
    #|        attrs=@html.Attrs::build().aria_label("Refresh"),
    #|        style=["margin-inline-start:auto"],
    #|        stroke_icon("M20 6v6h-6M4 18v-6h6M5.1 9A7 7 0 0 1 16.5 5.5L20 9M4 15l3.5 3.5A7 7 0 0 0 18.9 15"),
    #|      ),
    #|      @rui.input_group_button(
    #|        size=@rui.InputButtonIconXs,
    #|        title="Copy editor content",
    #|        attrs=@html.Attrs::build().aria_label("Copy editor content"),
    #|        on_click=@clipboard.copy(@clipboard.Text("println(\"Hello, world!\")")),
    #|        stroke_icon("M8 8h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H10a2 2 0 0 1-2-2ZM4 16a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2"),
    #|      ),
    #|    ]),
    #|    @rui.input_group_addon(align=@rui.InputBlockEnd, [
    #|      @rui.input_group_text(style=["flex:1"], "Line 1, Column 1"),
    #|      @rui.input_group_button(
    #|        size=@rui.InputButtonSm,
    #|        variant=@rui.Default,
    #|        [@html.span("Run"), stroke_icon("M9 10 4 15l5 5M20 4v7a4 4 0 0 1-4 4H4")],
    #|      ),
    #|    ]),
    #|  ]),
    #|)
    #|
  )

///|
const FormsInputGroupCustomControlCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input_group([
  #|    @rui.input_group_control(
  #|      style=["field-sizing:content;min-height:4rem;max-height:10rem;resize:none"],
  #|      (attrs, style) => @html.textarea(
  #|        id="forms-variants-input-group-custom",
  #|        rows=1,
  #|        placeholder="Autoresize textarea...",
  #|        attrs=attrs,
  #|        style=style,
  #|        ([] : Array[@html.Html]),
  #|      ),
  #|    ),
  #|    @rui.input_group_addon(align=@rui.InputBlockEnd, [
  #|      @rui.input_group_button(
  #|        size=@rui.InputButtonSm,
  #|        variant=@rui.Default,
  #|        style=["margin-inline-start:auto"],
  #|        "Submit",
  #|      ),
  #|    ]),
  #|  ]),
  #|)
  #|

///|
fn forms_input_group_variants() -> @rabbita.Val[@html.Html] {
  let connection_info = @rui.popover(
    id="forms-variants-input-group-connection-info",
    side=Bottom,
    align=Start,
    side_offset=8,
    trigger_variant=Secondary,
    trigger_size=IconXs,
    trigger_attrs=@html.Attrs::build().aria_label("Connection information"),
    trigger_style=["border-radius:9999px"],
    forms_input_group_info_icon(),
    @html.div(
      style=["display:flex;width:16rem;flex-direction:column;gap:0.25rem"],
      [
        @html.strong("Your connection is not secure."),
        @html.p(
          style=[
            "margin:0;color:var(--rui-muted-foreground);font-size:0.8125rem",
          ],
          "Do not enter sensitive information on this site.",
        ),
      ],
    ),
  )
  let favorite = @rui.toggle(
    id="forms-variants-input-group-favorite",
    size=Sm,
    aria_label="Favorite connection",
    style=[
      "width:1.5rem;height:1.5rem;min-width:1.5rem;padding:0;border-radius:9999px",
    ],
    forms_input_group_star_icon(),
  )
  let dropdown = @rui.dropdown_menu(
    id="forms-variants-input-group-dropdown-menu",
    scope => {
      @html.fragment([
        @rui.dropdown_menu_trigger(
          scope,
          variant=Ghost,
          size=IconXs,
          aria_label="More file actions",
          showcase_more_horizontal_icon(),
        ),
        @rui.dropdown_menu_portal([
          @rui.dropdown_menu_content(scope, align=End, side_offset=8, [
            @rui.dropdown_menu_item(scope, "Settings"),
            @rui.dropdown_menu_item(scope, "Copy path"),
            @rui.dropdown_menu_item(scope, "Open location"),
          ]),
        ]),
      ])
    },
  )
  let query_dropdown = @rui.dropdown_menu(
    id="forms-variants-input-group-query-menu",
    scope => {
      @html.fragment([
        @rui.dropdown_menu_trigger(
          scope,
          variant=Ghost,
          size=Xs,
          aria_label="Choose search scope",
          style=["gap:0.25rem;padding-inline:0.375rem;font-size:0.75rem"],
          [@html.span("Search in"), forms_input_group_chevron_down_icon()],
        ),
        @rui.dropdown_menu_portal([
          @rui.dropdown_menu_content(
            scope,
            align=End,
            side_offset=8,
            align_offset=-4,
            [
              @rui.dropdown_menu_item(scope, "Documentation"),
              @rui.dropdown_menu_item(scope, "Blog posts"),
              @rui.dropdown_menu_item(scope, "Changelog"),
            ],
          ),
        ]),
      ])
    },
  )
  connection_info.view4(favorite, dropdown, query_dropdown, (
    info_html,
    favorite_html,
    dropdown_html,
    query_dropdown_html,
  ) => {
    showcase_component_demos(
      "Input Group",
      "Add-ons, text, actions, loading feedback, and custom controls share one focused control surface.",
      [
        showcase_demo_section(
          "Basic",
          "A leading search icon and trailing result count share the input surface.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-basic",
                  placeholder="Search...",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-basic",
                  showcase_search_icon(),
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-basic",
                  @rui.input_group_text("12 results"),
                ),
              ]),
            ),
            FormsInputGroupBasicCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Inline start",
          "The add-on is first visually while the input remains first in focus order.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-inline-start",
                  placeholder="Search...",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-inline-start",
                  showcase_search_icon(),
                ),
              ]),
            ),
            FormsInputGroupInlineStartCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Inline end",
          "A trailing password affordance aligns without changing DOM order.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  input_type=Password,
                  id="forms-variants-input-group-inline-end",
                  placeholder="Enter password",
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-inline-end",
                  showcase_eye_off_icon(),
                ),
              ]),
            ),
            FormsInputGroupInlineEndCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Block start · input",
          "The group owns its stacked header layout without caller flex overrides.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-block-start",
                  placeholder="Enter your name",
                ),
                @rui.input_group_addon(
                  align=InputBlockStart,
                  for_="forms-variants-input-group-block-start",
                  @rui.input_group_text("Full name"),
                ),
              ]),
            ),
            FormsInputGroupBlockStartCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:13rem",
          ),
        ),
        showcase_demo_section(
          "Block start · textarea",
          "A file toolbar sits above the editable source without becoming a second card.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,26rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_textarea(
                  id="forms-variants-input-group-block-start-textarea",
                  rows=5,
                  placeholder="println(\"Hello, world!\")",
                ),
                @rui.input_group_addon(align=InputBlockStart, [
                  @rui.input_group_text([
                    showcase_file_icon(),
                    @html.span("script.mbt"),
                  ]),
                  @rui.input_group_button(
                    size=InputButtonIconXs,
                    title="Copy script",
                    attrs=@html.Attrs::build().aria_label("Copy script"),
                    style=["margin-inline-start:auto"],
                    on_click=@clipboard.copy(Text("println(\"Hello, world!\")")),
                    showcase_copy_icon(),
                  ),
                ]),
              ]),
            ),
            FormsInputGroupBlockStartTextareaCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:16rem",
          ),
        ),
        showcase_demo_section(
          "Block end · input",
          "A unit label occupies the full-width footer row below a compact amount input.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-block-end-input",
                  placeholder="Enter amount",
                ),
                @rui.input_group_addon(
                  align=InputBlockEnd,
                  @rui.input_group_text("USD"),
                ),
              ]),
            ),
            FormsInputGroupBlockEndInputCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:13rem",
          ),
        ),
        showcase_demo_section(
          "Block end · textarea",
          "A textarea footer keeps its count and action on one row.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,26rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_textarea(
                  id="forms-variants-input-group-block-end",
                  rows=4,
                  placeholder="Write a comment...",
                ),
                @rui.input_group_addon(align=InputBlockEnd, [
                  @rui.input_group_text(style=["flex:1"], "0/280"),
                  @rui.input_group_button(
                    size=InputButtonSm,
                    variant=Default,
                    "Post",
                  ),
                ]),
              ]),
            ),
            FormsInputGroupBlockEndCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:16rem",
          ),
        ),
        showcase_demo_section(
          "Icon · search",
          "A leading search icon identifies the input without competing with its placeholder.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-icon-search",
                  placeholder="Search...",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-icon-search",
                  showcase_search_icon(),
                ),
              ]),
            ),
            FormsInputGroupIconSearchCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Icon · email",
          "The mail icon preserves the native email field while sharing its focus ring.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  input_type=Email,
                  id="forms-variants-input-group-icon-email",
                  placeholder="Enter your email",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-icon-email",
                  showcase_mail_icon(),
                ),
              ]),
            ),
            FormsInputGroupIconEmailCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Icons · card validation",
          "Leading and trailing SVG icons communicate input type and validity.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-icons",
                  placeholder="Card number",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-icons",
                  showcase_credit_card_icon(),
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-icons",
                  showcase_check_icon(),
                ),
              ]),
            ),
            FormsInputGroupIconsCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Icons · metadata",
          "Trailing metadata icons can be grouped without creating extra focus targets.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-icon-metadata",
                  placeholder="Card number",
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-icon-metadata",
                  [forms_input_group_star_icon(), forms_input_group_info_icon()],
                ),
              ]),
            ),
            FormsInputGroupIconMetadataCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Text · currency",
          "Currency and unit labels frame a single amount field.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-text-currency",
                  placeholder="0.00",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-text-currency",
                  @rui.input_group_text("$"),
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-text-currency",
                  @rui.input_group_text("USD"),
                ),
              ]),
            ),
            FormsInputGroupTextCurrencyCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Text · URL",
          "Protocol and domain suffixes stay selectable as one URL control.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-text",
                  placeholder="example",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-text",
                  @rui.input_group_text("https://"),
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-text",
                  @rui.input_group_text(".com"),
                ),
              ]),
            ),
            FormsInputGroupTextCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Text · username suffix",
          "A fixed organization suffix clarifies the account name being entered.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-text-username",
                  placeholder="Enter your username",
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-text-username",
                  @rui.input_group_text("@company.com"),
                ),
              ]),
            ),
            FormsInputGroupTextUsernameCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Text · character count",
          "A textarea footer communicates the remaining character allowance.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,26rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_textarea(
                  id="forms-variants-input-group-text-count",
                  rows=4,
                  placeholder="Enter your message",
                ),
                @rui.input_group_addon(
                  align=InputBlockEnd,
                  @rui.input_group_text("120 characters left"),
                ),
              ]),
            ),
            FormsInputGroupTextCountCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:16rem",
          ),
        ),
        showcase_demo_section(
          "Button · copy",
          "An icon-only action uses the compact input-group button recipe.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-button",
                  value="https://rabbit-tea.dev",
                  read_only=true,
                ),
                @rui.input_group_addon(align=InputInlineEnd, [
                  @rui.input_group_button(
                    size=InputButtonIconXs,
                    title="Copy URL",
                    attrs=@html.Attrs::build().aria_label("Copy URL"),
                    on_click=@clipboard.copy(Text("https://rabbit-tea.dev")),
                    showcase_copy_icon(),
                  ),
                ]),
              ]),
            ),
            FormsInputGroupButtonsCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Buttons · connection actions",
          "Rounded info and favorite controls remain independently interactive inside the field.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,26rem);margin-inline:auto"],
              @rui.input_group(style=["--rui-radius:9999px"], [
                @rui.input_group_input(
                  id="forms-variants-input-group-secure",
                  value="rabbit-tea.dev",
                  read_only=true,
                ),
                @rui.input_group_addon(align=InputInlineStart, info_html),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-secure",
                  @rui.input_group_text("https://"),
                ),
                @rui.input_group_addon(align=InputInlineEnd, favorite_html),
              ]),
            ),
            FormsInputGroupConnectionButtonsCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:14rem",
          ),
        ),
        showcase_demo_section(
          "Button · search",
          "A compact text button submits the adjacent query without leaving the control surface.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-search-button",
                  placeholder="Type to search...",
                ),
                @rui.input_group_addon(align=InputInlineEnd, [
                  @rui.input_group_button(
                    size=InputButtonXs,
                    variant=Secondary,
                    "Search",
                  ),
                ]),
              ]),
            ),
            FormsInputGroupSearchButtonCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Keyboard shortcut",
          "The search input keeps a visible keyboard hint at its trailing edge.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-kbd",
                  placeholder="Search...",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  for_="forms-variants-input-group-kbd",
                  showcase_search_icon(),
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  for_="forms-variants-input-group-kbd",
                  @rui.kbd("⌘K"),
                ),
              ]),
            ),
            FormsInputGroupKbdCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Dropdown · icon trigger",
          "A compact trailing menu keeps popup state inside Dropdown Menu.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-dropdown",
                  placeholder="Enter file name",
                ),
                @rui.input_group_addon(align=InputInlineEnd, dropdown_html),
              ]),
            ),
            FormsInputGroupDropdownCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:14rem",
          ),
        ),
        showcase_demo_section(
          "Dropdown · text trigger",
          "A labelled scope menu provides a wider target while staying inside the group.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-query",
                  placeholder="Enter search query",
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  query_dropdown_html,
                ),
              ]),
            ),
            FormsInputGroupDropdownQueryCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:14rem",
          ),
        ),
        showcase_demo_section(
          "Spinner · trailing",
          "A trailing spinner reports a search without displacing the input text.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-spinner-trailing",
                  placeholder="Searching...",
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  @rui.spinner(label="Searching"),
                ),
              ]),
            ),
            FormsInputGroupSpinnerTrailingCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Spinner · leading",
          "A leading spinner communicates processing before the editable value.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-spinner-leading",
                  placeholder="Processing...",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  @rui.spinner(label="Processing"),
                ),
              ]),
            ),
            FormsInputGroupSpinnerLeadingCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Spinner · status text",
          "Status text and the animated spinner remain aligned at the end.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-loading",
                  placeholder="Saving changes...",
                ),
                @rui.input_group_addon(align=InputInlineEnd, [
                  @rui.input_group_text("Saving..."),
                  @rui.spinner(label="Saving changes"),
                ]),
              ]),
            ),
            FormsInputGroupLoadingCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Spinner · dual status",
          "Leading activity and trailing status text can describe one long-running operation.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_input(
                  id="forms-variants-input-group-spinner-status",
                  placeholder="Refreshing data...",
                ),
                @rui.input_group_addon(
                  align=InputInlineStart,
                  @rui.spinner(label="Refreshing data"),
                ),
                @rui.input_group_addon(
                  align=InputInlineEnd,
                  @rui.input_group_text("Please wait..."),
                ),
              ]),
            ),
            FormsInputGroupSpinnerStatusCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:12rem",
          ),
        ),
        showcase_demo_section(
          "Textarea toolbar",
          "A code textarea owns separate file and action toolbars.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,30rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_textarea(
                  id="forms-variants-input-group-editor",
                  rows=7,
                  placeholder="println(\"Hello, world!\")",
                ),
                @rui.input_group_addon(align=InputBlockStart, [
                  @rui.input_group_text([
                    showcase_file_icon(),
                    @html.span("main.mbt"),
                  ]),
                  @rui.input_group_button(
                    size=InputButtonIconXs,
                    title="Refresh",
                    attrs=@html.Attrs::build().aria_label("Refresh"),
                    style=["margin-inline-start:auto"],
                    showcase_refresh_icon(),
                  ),
                  @rui.input_group_button(
                    size=InputButtonIconXs,
                    title="Copy editor content",
                    attrs=@html.Attrs::build().aria_label("Copy editor content"),
                    on_click=@clipboard.copy(Text("println(\"Hello, world!\")")),
                    showcase_copy_icon(),
                  ),
                ]),
                @rui.input_group_addon(align=InputBlockEnd, [
                  @rui.input_group_text(style=["flex:1"], "Line 1, Column 1"),
                  @rui.input_group_button(size=InputButtonSm, variant=Default, [
                    @html.span("Run"),
                    showcase_corner_down_left_icon(),
                  ]),
                ]),
              ]),
            ),
            FormsInputGroupTextareaToolbarCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:22rem",
          ),
        ),
        showcase_demo_section(
          "Custom control",
          "A native content-sized textarea joins the group through the control slot.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,24rem);margin-inline:auto"],
              @rui.input_group([
                @rui.input_group_control(
                  style=[
                    "field-sizing:content;min-height:4rem;max-height:10rem;resize:none",
                  ],
                  (attrs, style) => {
                    @html.textarea(
                      id="forms-variants-input-group-custom",
                      rows=1,
                      placeholder="Autoresize textarea...",
                      attrs~,
                      style~,
                      ([] : Array[@html.Html]),
                    )
                  },
                ),
                @rui.input_group_addon(align=InputBlockEnd, [
                  @rui.input_group_button(
                    size=InputButtonSm,
                    variant=Default,
                    style=["margin-inline-start:auto"],
                    "Submit",
                  ),
                ]),
              ]),
            ),
            FormsInputGroupCustomControlCode,
            variant=ShowcaseStageSurface,
            stage_style="--rui-showcase-stage-min-height:16rem",
          ),
        ),
      ],
    )
  })
}
