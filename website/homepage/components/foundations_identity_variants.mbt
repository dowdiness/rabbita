///|
const IdentityVariantsGridStyle : String = "display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,14rem),1fr));gap:1rem;align-items:start"

///|
const IdentityVariantStyle : String = "display:flex;min-width:0;flex-direction:column;gap:0.75rem"

///|
const IdentityVariantLabelStyle : String = "margin:0;color:var(--rui-muted-foreground);font-size:0.8125rem;line-height:1.25rem;font-weight:500"

///|
const IdentitySurfaceStyle : String = "box-sizing:border-box;min-width:0;padding:0.25rem"

///|
const IdentityAspectSurfaceStyle : String = "display:flex;align-items:center;justify-content:center;border:1px solid var(--rui-border);border-radius:calc(var(--rui-radius) - 0.125rem);background:color-mix(in oklab,var(--rui-muted) 55%,var(--rui-background));color:var(--rui-muted-foreground);font-size:0.8125rem;font-weight:600"

///|
const IdentityAvatarImage : String = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' rx='16' fill='%2318171b'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%23fafafa'/%3E%3Cpath d='M14 80c2-20 12-31 26-31s24 11 26 31' fill='%23fafafa'/%3E%3C/svg%3E"

///|
const IdentityAvatarDefaultCode : String =
  #|@rui.avatar(@rui.avatar_fallback("AV"))
  #|

///|
const IdentityAvatarSmallCode : String =
  #|@rui.avatar(size=@rui.Sm, @rui.avatar_fallback("SM"))
  #|

///|
const IdentityAvatarLargeCode : String =
  #|@rui.avatar(size=@rui.Lg, @rui.avatar_fallback("LG"))
  #|

///|
const IdentityAvatarImageCode : String =
  #|@rui.avatar(size=@rui.Lg, [
  #|  @rui.avatar_image(
  #|    src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' rx='16' fill='%2318171b'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%23fafafa'/%3E%3Cpath d='M14 80c2-20 12-31 26-31s24 11 26 31' fill='%23fafafa'/%3E%3C/svg%3E",
  #|    alt="Alex Rivera",
  #|    width=80,
  #|    height=80,
  #|  ),
  #|  @rui.avatar_fallback("AR"),
  #|  @rui.avatar_badge(""),
  #|])
  #|

///|
const IdentityAvatarGroupCode : String =
  #|@rui.avatar_group([
  #|  @rui.avatar(@rui.avatar_fallback("YO")),
  #|  @rui.avatar(@rui.avatar_fallback("RA")),
  #|  @rui.avatar(@rui.avatar_fallback("MB")),
  #|  @rui.avatar_group_count("+4"),
  #|])
  #|

///|
const IdentityCardDefaultCode : String =
  #|@rui.card([
  #|  @rui.card_header([
  #|    @rui.card_title("Release notes"),
  #|    @rui.card_description("Review the changes included in this release."),
  #|    @rui.card_action(@rui.button(variant=@rui.Ghost, size=@rui.Sm, "Open")),
  #|  ]),
  #|  @rui.card_content(@html.p("The component package is ready for review.")),
  #|  @rui.card_footer(@rui.button(size=@rui.Sm, "Review")),
  #|])
  #|

///|
const IdentityCardSmallCode : String =
  #|@rui.card(size=@rui.Sm, [
  #|  @rui.card_header([
  #|    @rui.card_title("Preview build"),
  #|    @rui.card_description("A compact card using the same composition."),
  #|    @rui.card_action(@rui.button(variant=@rui.Ghost, size=@rui.Xs, "Open")),
  #|  ]),
  #|  @rui.card_content(@html.p("Checks passed and the preview is available.")),
  #|  @rui.card_footer(@rui.button(size=@rui.Xs, "View")),
  #|])
  #|

///|
const IdentityAspectSquareCode : String =
  #|@rui.aspect_ratio(
  #|  ratio=1.0,
  #|  style=["display:flex;align-items:center;justify-content:center;border:1px solid var(--rui-border);border-radius:calc(var(--rui-radius) - 0.125rem);background:color-mix(in oklab,var(--rui-muted) 55%,var(--rui-background));color:var(--rui-muted-foreground);font-size:0.8125rem;font-weight:600"],
  #|  @html.span("1:1"),
  #|)
  #|

///|
const IdentityAspectStandardCode : String =
  #|@rui.aspect_ratio(
  #|  ratio=1.3333333333,
  #|  style=["display:flex;align-items:center;justify-content:center;border:1px solid var(--rui-border);border-radius:calc(var(--rui-radius) - 0.125rem);background:color-mix(in oklab,var(--rui-muted) 55%,var(--rui-background));color:var(--rui-muted-foreground);font-size:0.8125rem;font-weight:600"],
  #|  @html.span("4:3"),
  #|)
  #|

///|
const IdentityAspectWidescreenCode : String =
  #|@rui.aspect_ratio(
  #|  ratio=1.7777777778,
  #|  style=["display:flex;align-items:center;justify-content:center;border:1px solid var(--rui-border);border-radius:calc(var(--rui-radius) - 0.125rem);background:color-mix(in oklab,var(--rui-muted) 55%,var(--rui-background));color:var(--rui-muted-foreground);font-size:0.8125rem;font-weight:600"],
  #|  @html.span("16:9"),
  #|)
  #|

///|
const IdentitySeparatorHorizontalCode : String =
  #|@html.div(style=["box-sizing:border-box;min-width:0;padding:0.25rem", "display:flex;flex-direction:column;gap:0.75rem"], [
  #|  @html.span("Release"),
  #|  @rui.separator(orientation=@rui.Horizontal),
  #|  @html.span("Activity"),
  #|])
  #|

///|
const IdentitySeparatorVerticalCode : String =
  #|@html.div(style=["box-sizing:border-box;min-width:0;padding:0.25rem", "display:flex;min-height:4rem;align-items:center;gap:1rem"], [
  #|  @html.span("Release"),
  #|  @rui.separator(orientation=@rui.Vertical, style=["height:2.5rem"]),
  #|  @html.span("Activity"),
  #|])
  #|

///|
const IdentityDirectionCode : String =
  #|fn direction_demo() -> @html.Html {
  #|  let variant = fn(label, body) {
  #|    @html.div(
  #|      style=["display:flex;min-width:0;flex-direction:column;gap:0.75rem"],
  #|      [
  #|        @html.p(
  #|          style=["margin:0;color:var(--rui-muted-foreground);font-size:0.8125rem;line-height:1.25rem;font-weight:500"],
  #|          label,
  #|        ),
  #|        body,
  #|      ],
  #|    )
  #|  }
  #|  @html.div(
  #|    style=["display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,14rem),1fr));gap:1rem;align-items:start"],
  #|    [
  #|      variant("Ltr", @rui.direction(
  #|        direction=@rui.Ltr,
  #|        style=["box-sizing:border-box;min-width:0;padding:0.25rem", "text-align:start"],
  #|        [
  #|          @html.div(style=["font-weight:600"], "Build complete"),
  #|          @html.div(
  #|            style=["margin-top:0.25rem;color:var(--rui-muted-foreground);font-size:0.8125rem"],
  #|            "The release is ready to publish.",
  #|          ),
  #|        ],
  #|      )),
  #|      variant("Rtl", @rui.direction(
  #|        direction=@rui.Rtl,
  #|        style=["box-sizing:border-box;min-width:0;padding:0.25rem", "text-align:start"],
  #|        [
  #|          @html.div(style=["font-weight:600"], "اكتمل البناء"),
  #|          @html.div(
  #|            style=["margin-top:0.25rem;color:var(--rui-muted-foreground);font-size:0.8125rem"],
  #|            "الإصدار جاهز للنشر.",
  #|          ),
  #|        ],
  #|      )),
  #|    ],
  #|  )
  #|}
  #|

///|
fn identity_variant(label : String, body : @html.Html) -> @html.Html {
  @html.div(style=[IdentityVariantStyle], [
    @html.p(style=[IdentityVariantLabelStyle], label),
    body,
  ])
}

///|
fn identity_component_demo(
  title : String,
  description : String,
  variant_title : String,
  variant_description : String,
  body : @html.Html,
  code : String,
  tall? : Bool = false,
  stage_variant? : ShowcaseStageVariant = ShowcaseStageSurface,
) -> @html.Html {
  showcase_component_demos(title, description, [
    showcase_demo_section(
      variant_title,
      variant_description,
      showcase_demo_stage(body, code, variant=stage_variant, tall~),
    ),
  ])
}

///|
fn identity_demo_section(
  title : String,
  description : String,
  body : @html.Html,
  code : String,
  tall? : Bool = false,
  stage_variant? : ShowcaseStageVariant = ShowcaseStageSurface,
) -> ShowcaseDemoEntry {
  showcase_demo_section(
    title,
    description,
    showcase_demo_stage(body, code, variant=stage_variant, tall~),
  )
}

///|
fn foundations_avatar_demo() -> @html.Html {
  showcase_component_demos(
    "Avatar",
    "Fallbacks, images, badges, sizes, and grouped identities.",
    [
      identity_demo_section(
        "Default",
        "Default fallback avatar.",
        @html.div(style=[IdentitySurfaceStyle], [
          @rui.avatar(@rui.avatar_fallback("AV")),
        ]),
        IdentityAvatarDefaultCode,
      ),
      identity_demo_section(
        "Small",
        "Small fallback avatar.",
        @html.div(style=[IdentitySurfaceStyle], [
          @rui.avatar(size=Sm, @rui.avatar_fallback("SM")),
        ]),
        IdentityAvatarSmallCode,
      ),
      identity_demo_section(
        "Large",
        "Large fallback avatar.",
        @html.div(style=[IdentitySurfaceStyle], [
          @rui.avatar(size=Lg, @rui.avatar_fallback("LG")),
        ]),
        IdentityAvatarLargeCode,
      ),
      identity_demo_section(
        "Image and badge",
        "Image, fallback, and badge form one avatar.",
        @html.div(style=[IdentitySurfaceStyle], [
          @rui.avatar(size=Lg, [
            @rui.avatar_image(
              src=IdentityAvatarImage,
              alt="Alex Rivera",
              width=80,
              height=80,
            ),
            @rui.avatar_fallback("AR"),
            @rui.avatar_badge(""),
          ]),
        ]),
        IdentityAvatarImageCode,
      ),
      identity_demo_section(
        "Group and count",
        "Overlapping avatars with an overflow count.",
        @html.div(style=[IdentitySurfaceStyle], [
          @rui.avatar_group([
            @rui.avatar(@rui.avatar_fallback("YO")),
            @rui.avatar(@rui.avatar_fallback("RA")),
            @rui.avatar(@rui.avatar_fallback("MB")),
            @rui.avatar_group_count("+4"),
          ]),
        ]),
        IdentityAvatarGroupCode,
      ),
    ],
  )
}

///|
fn foundations_card_demo() -> @html.Html {
  showcase_component_demos(
    "Card",
    "Default and compact compositions with headers, actions, content, and footers.",
    [
      identity_demo_section(
        "Default",
        "Default card composition.",
        @rui.card([
          @rui.card_header([
            @rui.card_title("Release notes"),
            @rui.card_description(
              "Review the changes included in this release.",
            ),
            @rui.card_action(@rui.button(variant=Ghost, size=Sm, "Open")),
          ]),
          @rui.card_content(
            @html.p("The component package is ready for review."),
          ),
          @rui.card_footer(@rui.button(size=Sm, "Review")),
        ]),
        IdentityCardDefaultCode,
        tall=true,
      ),
      identity_demo_section(
        "Small",
        "Compact card composition.",
        @rui.card(size=Sm, [
          @rui.card_header([
            @rui.card_title("Preview build"),
            @rui.card_description("A compact card using the same composition."),
            @rui.card_action(@rui.button(variant=Ghost, size=Xs, "Open")),
          ]),
          @rui.card_content(
            @html.p("Checks passed and the preview is available."),
          ),
          @rui.card_footer(@rui.button(size=Xs, "View")),
        ]),
        IdentityCardSmallCode,
        tall=true,
      ),
    ],
  )
}

///|
fn foundations_aspect_ratio_demo() -> @html.Html {
  showcase_component_demos(
    "Aspect Ratio",
    "Common media proportions keep their geometry across responsive widths.",
    [
      identity_demo_section(
        "Square (1:1)",
        "Square media frame.",
        @rui.aspect_ratio(
          ratio=1.0,
          style=[IdentityAspectSurfaceStyle],
          @html.span("1:1"),
        ),
        IdentityAspectSquareCode,
        stage_variant=ShowcaseStagePlain,
      ),
      identity_demo_section(
        "Standard (4:3)",
        "Traditional landscape frame.",
        @rui.aspect_ratio(
          ratio=1.3333333333,
          style=[IdentityAspectSurfaceStyle],
          @html.span("4:3"),
        ),
        IdentityAspectStandardCode,
        stage_variant=ShowcaseStagePlain,
      ),
      identity_demo_section(
        "Widescreen (16:9)",
        "Widescreen media frame.",
        @rui.aspect_ratio(
          ratio=1.7777777778,
          style=[IdentityAspectSurfaceStyle],
          @html.span("16:9"),
        ),
        IdentityAspectWidescreenCode,
        stage_variant=ShowcaseStagePlain,
      ),
    ],
  )
}

///|
fn foundations_direction_demo() -> @html.Html {
  identity_component_demo(
    "Direction",
    "Left-to-right and right-to-left content share the same component surface.",
    "Writing directions",
    "Logical alignment follows the local direction without changing the component API.",
    @html.div(style=[IdentityVariantsGridStyle], [
      identity_variant(
        "Ltr",
        @rui.direction(
          direction=Ltr,
          style=[IdentitySurfaceStyle, "text-align:start"],
          [
            @html.div(style=["font-weight:600"], "Build complete"),
            @html.div(
              style=[
                "margin-top:0.25rem;color:var(--rui-muted-foreground);font-size:0.8125rem",
              ],
              "The release is ready to publish.",
            ),
          ],
        ),
      ),
      identity_variant(
        "Rtl",
        @rui.direction(
          direction=Rtl,
          style=[IdentitySurfaceStyle, "text-align:start"],
          [
            @html.div(style=["font-weight:600"], "اكتمل البناء"),
            @html.div(
              style=[
                "margin-top:0.25rem;color:var(--rui-muted-foreground);font-size:0.8125rem",
              ],
              "الإصدار جاهز للنشر.",
            ),
          ],
        ),
      ),
    ]),
    IdentityDirectionCode,
    stage_variant=ShowcaseStagePlain,
  )
}

///|
fn foundations_separator_demo() -> @html.Html {
  showcase_component_demos(
    "Separator",
    "Horizontal and vertical separators divide related content without adding a container.",
    [
      identity_demo_section(
        "Horizontal",
        "A horizontal separator divides stacked content.",
        @html.div(
          style=[
            IdentitySurfaceStyle,
            "display:flex;flex-direction:column;gap:0.75rem",
          ],
          [
            @html.span("Release"),
            @rui.separator(orientation=Horizontal),
            @html.span("Activity"),
          ],
        ),
        IdentitySeparatorHorizontalCode,
      ),
      identity_demo_section(
        "Vertical",
        "A vertical separator divides inline content.",
        @html.div(
          style=[
            IdentitySurfaceStyle,
            "display:flex;min-height:4rem;align-items:center;gap:1rem",
          ],
          [
            @html.span("Release"),
            @rui.separator(orientation=Vertical, style=["height:2.5rem"]),
            @html.span("Activity"),
          ],
        ),
        IdentitySeparatorVerticalCode,
      ),
    ],
  )
}
