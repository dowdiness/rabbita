///|
const IgCollapsibleWidthStyle : String = "width:min(100%,26rem);margin-inline:auto"

///|
const IgCollapsibleTriggerStyle : String = "min-height:2.5rem;padding:0.5rem 0.625rem;border:1px solid var(--rui-accordion-border,transparent);border-radius:var(--rui-radius);background:var(--rui-accordion-bg,transparent);text-decoration:none"

///|
const IgCollapsibleCardStyle : String = "width:min(100%,28rem);margin-inline:auto;border:1px solid var(--rui-border);border-radius:var(--rui-radius);background:var(--rui-card);box-shadow:0 1px 2px rgb(0 0 0 / 0.04)"

///|
const IgCollapsibleCardTriggerStyle : String = "min-height:3.75rem;padding:0.75rem 1rem;border:0;border-radius:calc(var(--rui-radius) - 1px);background:var(--rui-accordion-bg,transparent);text-decoration:none"

///|
const IgCollapsibleCardBodyStyle : String = "padding:0 1rem 1rem;color:var(--rui-foreground);font-size:0.875rem"

///|
const IgCollapsibleTreeCardStyle : String = "width:min(100%,16rem);margin-inline:auto;gap:0.5rem"

///|
const IgCollapsibleTreeListStyle : String = "display:flex;min-width:0;flex-direction:column;gap:0.25rem"

///|
const IgCollapsibleTreeTriggerStyle : String = "min-height:2rem;padding:0.25rem 0.375rem;border:1px solid var(--rui-accordion-border,transparent);border-radius:calc(var(--rui-radius) - 0.25rem);background:var(--rui-accordion-bg,transparent);font-weight:400;text-decoration:none"

///|
const IgCollapsibleTreeChildrenStyle : String = "display:flex;min-width:0;flex-direction:column;padding-inline-start:1.125rem"

///|
const IgCollapsibleTreeLeafStyle : String = "display:flex;min-height:2rem;min-width:0;align-items:center;gap:0.5rem;padding:0.25rem 0.375rem;color:var(--rui-foreground);font-size:0.875rem;line-height:1.25rem"

///|
fn ig_collapsible_order_view() -> @rabbita.Val[@html.Html] {
  @rui.collapsible(
    id="showcase-collapsible-order",
    default_open=true,
    style=[IgCollapsibleCardStyle],
    trigger_style=[IgCollapsibleCardTriggerStyle],
    content_body_style=[IgCollapsibleCardBodyStyle],
    trigger=@html.span(
      style=[
        "display:flex;min-width:0;align-items:center;justify-content:space-between;gap:0.75rem;text-align:start",
      ],
      [
        @html.span(style=["display:grid;min-width:0;gap:0.125rem"], [
          @html.strong("Order #4189"),
          @html.span(style=[MutedStyle], "July 16 · 2 items"),
        ]),
        @rui.badge(variant=Secondary, "Paid"),
      ],
    ),
    content=@html.div(style=["display:grid;gap:0.625rem"], [
      @html.div(style=["display:flex;justify-content:space-between;gap:1rem"], [
        @html.span("UI component license"),
        @html.strong("$49.00"),
      ]),
      @html.div(style=["display:flex;justify-content:space-between;gap:1rem"], [
        @html.span("Icon pack"),
        @html.strong("$16.00"),
      ]),
      @html.hr(style=[
        "width:100%;height:1px;border:0;background:var(--rui-border);margin:0.125rem 0",
      ]),
      @html.div(style=["display:flex;justify-content:space-between;gap:1rem"], [
        @html.strong("Total"),
        @html.strong("$65.00"),
      ]),
    ]),
  )
}

///|
fn ig_collapsible_basic_view() -> @rabbita.Val[@html.Html] {
  @rui.collapsible(
    id="showcase-collapsible-basic",
    style=[IgCollapsibleWidthStyle],
    trigger_style=[IgCollapsibleTriggerStyle],
    content_body_style=["padding:0.25rem 0.625rem 0.75rem"],
    trigger="Can I use this in my project?",
    content=@html.p(
      style=[MutedStyle, "margin:0"],
      "Yes. The component owns its state, ARIA relationship, and keyboard activation.",
    ),
  )
}

///|
fn ig_collapsible_settings_view() -> @rabbita.Val[@html.Html] {
  @rui.collapsible(
    id="showcase-collapsible-settings",
    style=[IgCollapsibleCardStyle],
    trigger_style=[IgCollapsibleCardTriggerStyle],
    content_body_style=[IgCollapsibleCardBodyStyle],
    trigger=@html.span(
      style=[
        "display:flex;min-width:0;align-items:center;gap:0.75rem;text-align:start",
      ],
      [
        showcase_settings_icon(),
        @html.span(style=["display:grid;min-width:0;gap:0.125rem"], [
          @html.strong("Advanced settings"),
          @html.span(style=[MutedStyle], "Configure the generated workspace"),
        ]),
      ],
    ),
    content=@html.div(style=["display:grid;gap:0.875rem"], [
      @html.div(style=["display:grid;gap:0.375rem"], [
        @rui.label(for_="collapsible-workspace-name", "Workspace name"),
        @rui.input(id="collapsible-workspace-name", value="Rabbit Tea"),
      ]),
      @html.div(style=["display:grid;gap:0.375rem"], [
        @rui.label(for_="collapsible-release-channel", "Release channel"),
        @rui.input(id="collapsible-release-channel", value="Stable"),
      ]),
    ]),
  )
}

///|
fn ig_collapsible_tree_leaf(name : String) -> @html.Html {
  @html.div(style=[IgCollapsibleTreeLeafStyle], [
    showcase_file_icon(),
    @html.span(
      style=[
        "min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap",
      ],
      name,
    ),
  ])
}

///|
fn ig_collapsible_tree_folder(
  open_paths : Array[String],
  set_path_open : @rabbita.Emit[(String, Bool)],
  path : String,
  name : String,
  children : Array[@html.Html],
) -> @html.Html {
  let open = open_paths.contains(path)
  let trigger_id = "showcase-file-tree-" + path + "-trigger"
  let content_id = "showcase-file-tree-" + path + "-content"
  let on_open_change = set_path_open.map(next => (path, next))
  @rui.collapsible_root(
    open~,
    attrs=@html.Attrs::build().data_set("path", path),
    [
      @rui.collapsible_trigger(
        open~,
        controls=content_id,
        show_indicator=false,
        on_open_change~,
        id=trigger_id,
        style=[IgCollapsibleTreeTriggerStyle],
        @html.span(
          style=["display:flex;min-width:0;align-items:center;gap:0.5rem"],
          [
            @html.span(
              style=[
                "display:inline-flex;flex:none;transition:transform 150ms ease;transform:\{if open { "rotate(90deg)" } else { "rotate(0deg)" }}",
              ],
              showcase_chevron_right_icon(),
            ),
            if open {
              showcase_folder_open_icon()
            } else {
              showcase_folder_icon()
            },
            @html.span(
              style=[
                "min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap",
              ],
              name,
            ),
          ],
        ),
      ),
      @rui.collapsible_content(
        open~,
        labelledby=trigger_id,
        id=content_id,
        body_style=["padding:0;color:var(--rui-foreground);font-size:0.875rem"],
        @html.div(style=[IgCollapsibleTreeChildrenStyle], children),
      ),
    ],
  )
}

///|
fn ig_collapsible_next_open_paths(
  current : Array[String],
  path : String,
  open : Bool,
) -> Array[String] {
  if open {
    if current.contains(path) {
      current
    } else {
      let next = current.copy()
      next.push(path)
      next
    }
  } else {
    current.filter(item => item != path)
  }
}

///|
fn ig_collapsible_file_tree_view() -> @rabbita.Val[@html.Html] {
  let view_tabs = @rui.tabs(
    id="showcase-file-tree-tabs",
    default_value="explorer",
    aria_label="File tree view",
    style=["gap:0"],
    list_style=["width:100%"],
    content_style=["display:none"],
    items=[
      @rui.tab_entry(value="explorer", label="Explorer", content=@html.nothing),
      @rui.tab_entry(value="outline", label="Outline", content=@html.nothing),
    ],
  )
  let (open_paths, set_open_paths) = @rabbita.create_variable([
    "components", "components/ui", "lib",
  ])
  let set_path_open = set_open_paths.map(change => {
    current => {
      let (path, open) = change
      ig_collapsible_next_open_paths(current, path, open)
    }
  })
  open_paths.view2(view_tabs, (open_paths, tabs_html) => {
    let components_ui = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "components/ui",
      "ui",
      [
        ig_collapsible_tree_leaf("button.mbt"),
        ig_collapsible_tree_leaf("card.mbt"),
        ig_collapsible_tree_leaf("dialog.mbt"),
        ig_collapsible_tree_leaf("input.mbt"),
        ig_collapsible_tree_leaf("select.mbt"),
        ig_collapsible_tree_leaf("table.mbt"),
      ],
    )
    let components = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "components",
      "components",
      [
        components_ui,
        ig_collapsible_tree_leaf("login-form.mbt"),
        ig_collapsible_tree_leaf("register-form.mbt"),
      ],
    )
    let lib = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "lib",
      "lib",
      [
        ig_collapsible_tree_leaf("utils.mbt"),
        ig_collapsible_tree_leaf("cn.mbt"),
        ig_collapsible_tree_leaf("api.mbt"),
      ],
    )
    let hooks = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "hooks",
      "hooks",
      [
        ig_collapsible_tree_leaf("use-media-query.mbt"),
        ig_collapsible_tree_leaf("use-debounce.mbt"),
        ig_collapsible_tree_leaf("use-local-storage.mbt"),
      ],
    )
    let types = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "types",
      "types",
      [
        ig_collapsible_tree_leaf("index.d.mbt"),
        ig_collapsible_tree_leaf("api.d.mbt"),
      ],
    )
    let public_images = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "public/images",
      "images",
      [ig_collapsible_tree_leaf("workspace.png")],
    )
    let public = ig_collapsible_tree_folder(
      open_paths,
      set_path_open,
      "public",
      "public",
      [
        ig_collapsible_tree_leaf("favicon.ico"),
        ig_collapsible_tree_leaf("logo.svg"),
        public_images,
      ],
    )
    @rui.card(size=Sm, style=[IgCollapsibleTreeCardStyle], [
      @rui.card_header(tabs_html),
      @rui.card_content(
        @html.div(style=[IgCollapsibleTreeListStyle], [
          components,
          lib,
          hooks,
          types,
          public,
          ig_collapsible_tree_leaf("app.mbt"),
          ig_collapsible_tree_leaf("layout.mbt"),
          ig_collapsible_tree_leaf("globals.css"),
          ig_collapsible_tree_leaf("moon.pkg"),
          ig_collapsible_tree_leaf("moon.mod"),
          ig_collapsible_tree_leaf("README.md"),
          ig_collapsible_tree_leaf(".gitignore"),
        ]),
      ),
    ])
  })
}

///|
fn ig_collapsible_component(
  order_html : @html.Html,
  basic_html : @html.Html,
  settings_html : @html.Html,
  file_tree_html : @html.Html,
) -> @html.Html {
  showcase_component_demos(
    "Collapsible",
    "Disclosure patterns from compact details to independently controlled tree branches.",
    [
      showcase_demo_section(
        "Order details",
        "A summary card reveals line items without leaving the current context.",
        showcase_demo_stage(order_html, IgCollapsibleOrderCode),
      ),
      showcase_demo_section(
        "Basic",
        "The black-box component owns open state and trigger-to-panel relationships.",
        showcase_demo_stage(basic_html, IgCollapsibleBasicCode),
      ),
      showcase_demo_section(
        "Settings panel",
        "Rich trigger and panel content compose through the same public API.",
        showcase_demo_stage(settings_html, IgCollapsibleSettingsCode),
      ),
      showcase_demo_section(
        "File tree",
        "Every folder is keyed by its full path, so nested open state survives parent toggles.",
        showcase_demo_stage(
          file_tree_html,
          IgCollapsibleFileTreeCode,
          tall=true,
          stage_style="--rui-showcase-stage-min-height:34rem",
        ),
      ),
    ],
  )
}
