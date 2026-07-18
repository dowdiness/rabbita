///|
const ShowcaseComponentShellStyle : String = "box-sizing:border-box;display:grid;width:100%;min-width:0;grid-template-columns:var(--rui-showcase-component-columns,minmax(0,46rem) 11rem);justify-content:center;align-items:start;column-gap:clamp(2rem,3vw,3rem);grid-column:1 / -1;scroll-margin-top:calc(var(--nav-h,60px) + 1rem)"

///|
const ShowcaseComponentMainStyle : String = "box-sizing:border-box;display:flex;width:100%;min-width:0;flex-direction:column;gap:1rem"

///|
const ShowcasePageNavigationStyle : String = "box-sizing:border-box;display:grid;width:100%;grid-template-columns:minmax(0,1fr) minmax(0,1fr);align-items:stretch;gap:0.75rem"

///|
const ShowcasePageNavigationLinkStyle : String = "box-sizing:border-box;display:flex;min-width:0;min-height:3.25rem;align-items:center;gap:0.625rem;border:1px solid var(--rui-border);border-radius:calc(var(--rui-radius) - 0.125rem);background:var(--rui-background);padding:0.625rem 0.75rem;color:var(--rui-foreground);box-shadow:0 1px 2px rgb(0 0 0 / 0.04);text-decoration:none;outline:none;transition:background-color 150ms ease,border-color 150ms ease,box-shadow 150ms ease"

///|
const ShowcasePageNavigationNextStyle : String = "grid-column:2;justify-content:flex-end;text-align:end"

///|
const ShowcasePageNavigationTextStyle : String = "display:flex;min-width:0;flex-direction:column;gap:0.125rem"

///|
const ShowcasePageNavigationDirectionStyle : String = "color:var(--rui-muted-foreground);font-size:0.6875rem;line-height:1rem"

///|
const ShowcasePageNavigationTitleStyle : String = "min-width:0;overflow:hidden;font-size:0.8125rem;font-weight:600;line-height:1.125rem;text-overflow:ellipsis;white-space:nowrap"

///|
const ShowcaseComponentHeaderStyle : String = "box-sizing:border-box;display:flex;width:100%;min-width:0;flex-direction:column;align-items:flex-start;gap:0.375rem;margin:0;text-align:start"

///|
const ShowcaseComponentTitleStyle : String = "margin:0;font-size:clamp(1.375rem,2vw,1.75rem);line-height:1.2;font-weight:650;letter-spacing:-0.035em"

///|
const ShowcaseComponentDescriptionStyle : String = "max-width:42rem;margin:0;color:var(--rui-muted-foreground);font-size:0.9375rem;line-height:1.55"

///|
const ShowcaseComponentTocStyle : String = "position:sticky;top:calc(var(--nav-h,60px) + 1rem);min-width:0;padding-left:1rem;border-left:1px solid var(--rui-border)"

///|
const ShowcaseComponentTocLinkStyle : String = "display:block;padding:0.35rem 0;color:var(--rui-muted-foreground);font-size:0.75rem;line-height:1.2rem;text-decoration:none"

///|
priv enum ShowcaseStageVariant {
  ShowcaseStagePlain
  ShowcaseStageSurface
}

///|
priv enum ShowcasePreparedStage {
  PreparedShowcaseStage(@html.Html)
}

///|
priv enum ShowcaseDemoEntry {
  NamedShowcaseDemo(String, String, @html.Html)
}

///|
const ShowcaseComponentStageBodyStyle : String = "width:100%;min-width:0"

///|
const ShowcaseDemoListStyle : String = "box-sizing:border-box;display:flex;width:100%;min-width:0;flex-direction:column;gap:2.5rem"

///|
const ShowcaseDemoSectionStyle : String = "box-sizing:border-box;display:flex;width:100%;min-width:0;flex-direction:column;gap:1rem"

///|
const ShowcaseDemoSectionHeaderStyle : String = "box-sizing:border-box;display:flex;width:100%;min-width:0;flex-direction:column;align-items:flex-start;gap:0.375rem;margin:0;text-align:start"

///|
const ShowcaseDemoSectionTitleStyle : String = "margin:0;font-size:1.125rem;line-height:1.5rem;font-weight:650;letter-spacing:-0.02em"

///|
const ShowcaseDemoSectionDescriptionStyle : String = "max-width:42rem;margin:0;color:var(--rui-muted-foreground);font-size:0.875rem;line-height:1.5"

///|
const ShowcaseDemoFrameStyle : String = "box-sizing:border-box;width:100%;min-width:0;overflow:hidden;border:1px solid var(--rui-border);border-radius:calc(var(--rui-radius) + 0.375rem);background:var(--rui-background)"

///|
const ShowcaseDemoPreviewStyle : String = "box-sizing:border-box;display:flex;width:100%;min-width:0;min-height:var(--rui-showcase-stage-min-height,16rem);align-items:center;justify-content:center;padding:clamp(1.25rem,4vw,2.5rem)"

///|
const ShowcaseDemoPlainStyle : String = "background:var(--rui-background)"

///|
const ShowcaseDemoSurfaceStyle : String = "background:light-dark(color-mix(in oklab,var(--rui-muted) 35%,var(--rui-background)),var(--rui-background))"

///|
const ShowcaseDemoCodeStyle : String = "--rui-showcase-code-background:light-dark(color-mix(in oklab,var(--rui-muted) 65%,var(--rui-background)),var(--rui-card));border-top:1px solid var(--rui-border);background:var(--rui-showcase-code-background)"

///|
const ShowcaseDemoCodePeekStyle : String = "box-sizing:border-box;margin:0;overflow:hidden"

///|
const ShowcaseDemoCodePanelStyle : String = "position:absolute;inset:0 0 auto auto;z-index:3;width:4rem;height:3.25rem;pointer-events:none"

///|
const ShowcaseDemoCodeScrollStyle : String = "overflow-x:auto"

///|
const ShowcaseDemoCodeCopyStyle : String = "position:absolute;top:0.75rem;right:1rem;z-index:3;width:1.75rem;height:1.75rem;min-width:1.75rem;min-height:1.75rem;pointer-events:auto;--rui-button-base-bg:var(--rui-showcase-code-background);--rui-control-radius:0.375rem"

///|
const ShowcaseDemoCodeExpandedStyle : String = "max-height:none;overflow:visible"

///|
const ShowcaseDemoCodeReadableStyle : String = "pointer-events:auto;user-select:text"

///|
fn showcase_anchor(value : String) -> String {
  let builder = StringBuilder::new()
  let mut separator = false
  for character in value {
    match character {
      'A'..='Z' | 'a'..='z' | '0'..='9' => {
        if separator && !builder.is_empty() {
          builder.write_char('-')
        }
        builder.write_char(character)
        separator = false
      }
      _ => if !builder.is_empty() { separator = true }
    }
  }
  let anchor = builder.to_string()
  if anchor == "" {
    "component"
  } else {
    anchor
  }
}

///|
fn showcase_highlighted_code(code : String) -> @html.Html {
  @shiki.static_code(
    code,
    lang="moonbit",
    light_theme="github-light",
    dark_theme="github-dark-default",
  )
}

///|
fn showcase_component_anchor(title : String) -> String {
  "component-\{showcase_anchor(title)}"
}

///|
fn showcase_code_line_count(code : String) -> Int {
  let mut count = 1
  let mut ends_with_newline = false
  for character in code {
    ends_with_newline = character == '\n'
    if character == '\n' {
      count += 1
    }
  }
  if ends_with_newline && count > 1 {
    count - 1
  } else {
    count
  }
}

///|
fn showcase_code_copy_panel(code : String) -> @html.Html {
  @html.div(
    class="rui-showcase-demo-code-panel",
    style=[ShowcaseDemoCodePanelStyle],
    @rui.button(
      variant=@rui.Ghost,
      size=@rui.IconSm,
      class="rui-showcase-demo-code-copy",
      title="Copy code",
      attrs=@html.Attrs::build().aria_label("Copy code"),
      style=[ShowcaseDemoCodeCopyStyle],
      on_click=@clipboard.copy(@clipboard.Text(code)),
      showcase_copy_icon(),
    ),
  )
}

///|
fn showcase_component_header(
  title : String,
  description : String,
) -> @html.Html {
  @html.header(
    class="rui-showcase-component-header",
    style=[ShowcaseComponentHeaderStyle],
    [
      @html.h1(
        class="rui-showcase-component-title",
        style=[ShowcaseComponentTitleStyle],
        title,
      ),
      @html.p(style=[ShowcaseComponentDescriptionStyle], description),
    ],
  )
}

///|
fn showcase_page_navigation_link(
  entry : ShowcasePageEntry,
  next : Bool,
) -> @html.Html {
  let direction = if next { "Next" } else { "Previous" }
  let text = @html.span(style=[ShowcasePageNavigationTextStyle], [
    @html.span(style=[ShowcasePageNavigationDirectionStyle], direction),
    @html.span(style=[ShowcasePageNavigationTitleStyle], entry.title),
  ])
  @html.a(
    href=showcase_page_href(entry.slug),
    class=if next {
      "rui-showcase-page-navigation-link rui-showcase-page-navigation-link--next"
    } else {
      "rui-showcase-page-navigation-link rui-showcase-page-navigation-link--previous"
    },
    attrs=@html.Attrs::build().aria_label("\{direction}: \{entry.title}"),
    style=[
      ShowcasePageNavigationLinkStyle,
      if next {
        ShowcasePageNavigationNextStyle
      } else {
        ""
      },
    ],
    if next {
      [text, showcase_chevron_right_icon()]
    } else {
      [showcase_chevron_left_icon(), text]
    },
  )
}

///|
fn showcase_component_page_navigation(title : String) -> @html.Html {
  let index = showcase_page_index_by_title(title)
  @html.nav(
    class="rui-showcase-page-navigation",
    attrs=@html.Attrs::build().aria_label("Component pages"),
    style=[ShowcasePageNavigationStyle],
    [
      if index > 0 {
        showcase_page_navigation_link(showcase_page_entries[index - 1], false)
      } else {
        @html.nothing
      },
      if index >= 0 && index + 1 < showcase_page_entries.length() {
        showcase_page_navigation_link(showcase_page_entries[index + 1], true)
      } else {
        @html.nothing
      },
    ],
  )
}

///|
fn showcase_stage(
  body : @html.Html,
  code : String,
  variant? : ShowcaseStageVariant = ShowcaseStagePlain,
  tall? : Bool = false,
  stage_style? : String = "",
) -> @html.Html {
  let highlighted_code = showcase_highlighted_code(code)
  let show_full_code = showcase_code_line_count(code) < 5
  let preview_styles = [
    ShowcaseDemoPreviewStyle,
    if tall {
      "--rui-showcase-stage-min-height:22rem"
    } else {
      ""
    },
    match variant {
      ShowcaseStagePlain => ShowcaseDemoPlainStyle
      ShowcaseStageSurface => ShowcaseDemoSurfaceStyle
    },
    stage_style,
  ]
  @html.div(class="rui-showcase-demo-stage", style=[ShowcaseDemoFrameStyle], [
    @html.div(
      class="rui-showcase-demo-preview",
      style=preview_styles,
      @html.div(style=[ShowcaseComponentStageBodyStyle], body),
    ),
    @html.div(
      class=if show_full_code {
        "rui-showcase-demo-code rui-showcase-demo-code--expanded"
      } else {
        "rui-showcase-demo-code"
      },
      style=[
        ShowcaseDemoCodeStyle,
        if show_full_code {
          ShowcaseDemoCodeExpandedStyle
        } else {
          ""
        },
      ],
      [
        @html.div(
          class="rui-showcase-shiki rui-showcase-demo-code-peek rui-showcase-demo-code-scroll",
          style=[
            ShowcaseDemoCodePeekStyle,
            ShowcaseDemoCodeScrollStyle,
            if show_full_code {
              ShowcaseDemoCodeReadableStyle
            } else {
              ""
            },
          ],
          highlighted_code,
        ),
        if show_full_code {
          showcase_code_copy_panel(code)
        } else {
          @html.details(class="rui-showcase-demo-code-disclosure", [
            @html.summary(class="rui-showcase-demo-code-summary", [
              @html.span(class="rui-showcase-demo-code-toggle", "View Code"),
            ]),
            showcase_code_copy_panel(code),
          ])
        },
      ],
    ),
  ])
}

///|
fn showcase_demo_stage(
  body : @html.Html,
  code : String,
  variant? : ShowcaseStageVariant = ShowcaseStageSurface,
  tall? : Bool = false,
  stage_style? : String = "",
) -> ShowcasePreparedStage {
  PreparedShowcaseStage(
    showcase_stage(body, code, variant~, tall~, stage_style~),
  )
}

///|
fn showcase_demo_section(
  title : String,
  description : String,
  stage : ShowcasePreparedStage,
) -> ShowcaseDemoEntry {
  let stage_html = match stage {
    PreparedShowcaseStage(stage_html) => stage_html
  }
  NamedShowcaseDemo(title, description, stage_html)
}

///|
fn showcase_demo_entry_id(
  component_id : String,
  entry : ShowcaseDemoEntry,
) -> String {
  match entry {
    NamedShowcaseDemo(title, _, _) =>
      "\{component_id}--\{showcase_anchor(title)}"
  }
}

///|
fn showcase_demo_entry_label(entry : ShowcaseDemoEntry) -> String {
  match entry {
    NamedShowcaseDemo(title, _, _) => title
  }
}

///|
fn showcase_demo_entry_view(
  component_id : String,
  entry : ShowcaseDemoEntry,
) -> @html.Html {
  let id = showcase_demo_entry_id(component_id, entry)
  match entry {
    NamedShowcaseDemo(title, description, stage) =>
      @html.section(
        id~,
        class="rui-showcase-demo-section",
        style=[ShowcaseDemoSectionStyle],
        [
          @html.header(
            class="rui-showcase-demo-section-header",
            style=[ShowcaseDemoSectionHeaderStyle],
            [
              @html.h2(style=[ShowcaseDemoSectionTitleStyle], title),
              @html.p(style=[ShowcaseDemoSectionDescriptionStyle], description),
            ],
          ),
          stage,
        ],
      )
  }
}

///|
fn showcase_component_toc(
  title : String,
  component_id : String,
  entries : Array[ShowcaseDemoEntry],
) -> @html.Html {
  @html.aside(
    class="rui-showcase-component-toc",
    style=[ShowcaseComponentTocStyle],
    [
      @html.nav(
        attrs=@html.Attrs::build().aria_label("\{title} variants"),
        [
          for entry in entries => {
            rail_link(
              "#\{showcase_demo_entry_id(component_id, entry)}",
              showcase_demo_entry_label(entry),
              style=ShowcaseComponentTocLinkStyle,
            )
          }
        ],
      ),
    ],
  )
}

///|
fn showcase_component_demos(
  title : String,
  description : String,
  demos : Array[ShowcaseDemoEntry],
) -> @html.Html {
  let component_id = showcase_component_anchor(title)
  @html.section(
    id=component_id,
    class="rui-showcase-component",
    style=[ShowcaseComponentShellStyle],
    [
      @html.div(
        class="rui-showcase-component-main",
        style=[ShowcaseComponentMainStyle],
        [
          showcase_component_page_navigation(title),
          showcase_component_header(title, description),
          @html.div(
            style=[ShowcaseDemoListStyle],
            [
              for demo in demos => showcase_demo_entry_view(component_id, demo)
            ],
          ),
          showcase_component_page_navigation(title),
        ],
      ),
      showcase_component_toc(title, component_id, demos),
    ],
  )
}
