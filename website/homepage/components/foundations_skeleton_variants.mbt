///|
const FoundationsSkeletonDefaultCode : String =
  #|@html.div(
  #|  style=[
  #|    "display:flex;width:min(100%,19.625rem);margin-inline:auto;align-items:center;gap:1rem",
  #|  ],
  #|  [
  #|    @rui.skeleton(style=["width:3rem;height:3rem;flex:none;border-radius:9999px"]),
  #|    @html.div(
  #|      style=["display:flex;min-width:0;flex:1;flex-direction:column;gap:0.5rem"],
  #|      [
  #|        @rui.skeleton(style=["width:100%;height:1rem"]),
  #|        @rui.skeleton(style=["width:80%;height:1rem"]),
  #|      ],
  #|    ),
  #|  ],
  #|)
  #|

///|
const FoundationsSkeletonAvatarCode : String =
  #|@html.div(
  #|  style=[
  #|    "display:flex;width:min(100%,12.875rem);margin-inline:auto;align-items:center;gap:1rem",
  #|  ],
  #|  [
  #|    @rui.skeleton(style=["width:2.5rem;height:2.5rem;flex:none;border-radius:9999px"]),
  #|    @html.div(
  #|      style=["display:flex;min-width:0;flex:1;flex-direction:column;gap:0.5rem"],
  #|      [
  #|        @rui.skeleton(style=["width:100%;height:1rem"]),
  #|        @rui.skeleton(style=["width:66.667%;height:1rem"]),
  #|      ],
  #|    ),
  #|  ],
  #|)
  #|

///|
const FoundationsSkeletonCardCode : String =
  #|@rui.card(style=["width:min(100%,20rem);margin-inline:auto"], [
  #|  @rui.card_header([
  #|    @rui.skeleton(style=["width:66.667%;height:1rem"]),
  #|    @rui.skeleton(style=["width:50%;height:1rem"]),
  #|  ]),
  #|  @rui.card_content(
  #|    @rui.skeleton(style=["width:100%;aspect-ratio:16/9"]),
  #|  ),
  #|])
  #|

///|
const FoundationsSkeletonTextCode : String =
  #|@html.div(
  #|  style=[
  #|    "display:flex;width:min(100%,20rem);margin-inline:auto;flex-direction:column;gap:0.5rem",
  #|  ],
  #|  [
  #|    @rui.skeleton(style=["width:100%;height:1rem"]),
  #|    @rui.skeleton(style=["width:100%;height:1rem"]),
  #|    @rui.skeleton(style=["width:75%;height:1rem"]),
  #|  ],
  #|)
  #|

///|
const FoundationsSkeletonFormCode : String =
  #|@html.div(
  #|  style=[
  #|    "display:flex;width:min(100%,20rem);margin-inline:auto;flex-direction:column;gap:1.75rem",
  #|  ],
  #|  [
  #|    @html.div(style=["display:flex;flex-direction:column;gap:0.75rem"], [
  #|      @rui.skeleton(style=["width:5rem;height:1rem"]),
  #|      @rui.skeleton(style=["width:100%;height:2rem"]),
  #|    ]),
  #|    @html.div(style=["display:flex;flex-direction:column;gap:0.75rem"], [
  #|      @rui.skeleton(style=["width:6rem;height:1rem"]),
  #|      @rui.skeleton(style=["width:100%;height:2rem"]),
  #|    ]),
  #|    @rui.skeleton(style=["width:6rem;height:2rem"]),
  #|  ],
  #|)
  #|

///|
const FoundationsSkeletonTableCode : String =
  #|@html.div(
  #|  style=[
  #|    "display:flex;width:min(100%,24rem);margin-inline:auto;flex-direction:column;gap:0.5rem",
  #|  ],
  #|  [
  #|    for _row in 0..<5 => @html.div(
  #|      style=["display:flex;min-width:0;gap:1rem"],
  #|      [
  #|        @rui.skeleton(style=["height:1rem;min-width:0;flex:1"]),
  #|        @rui.skeleton(style=["width:6rem;max-width:25%;height:1rem"]),
  #|        @rui.skeleton(style=["width:5rem;max-width:25%;height:1rem"]),
  #|      ],
  #|    )
  #|  ],
  #|)
  #|

///|
fn foundations_skeleton_default() -> @html.Html {
  @html.div(
    style=[
      "display:flex;width:min(100%,19.625rem);margin-inline:auto;align-items:center;gap:1rem",
    ],
    [
      @rui.skeleton(style=[
        "width:3rem;height:3rem;flex:none;border-radius:9999px",
      ]),
      @html.div(
        style=[
          "display:flex;min-width:0;flex:1;flex-direction:column;gap:0.5rem",
        ],
        [
          @rui.skeleton(style=["width:100%;height:1rem"]),
          @rui.skeleton(style=["width:80%;height:1rem"]),
        ],
      ),
    ],
  )
}

///|
fn foundations_skeleton_avatar() -> @html.Html {
  @html.div(
    style=[
      "display:flex;width:min(100%,12.875rem);margin-inline:auto;align-items:center;gap:1rem",
    ],
    [
      @rui.skeleton(style=[
        "width:2.5rem;height:2.5rem;flex:none;border-radius:9999px",
      ]),
      @html.div(
        style=[
          "display:flex;min-width:0;flex:1;flex-direction:column;gap:0.5rem",
        ],
        [
          @rui.skeleton(style=["width:100%;height:1rem"]),
          @rui.skeleton(style=["width:66.667%;height:1rem"]),
        ],
      ),
    ],
  )
}

///|
fn foundations_skeleton_card() -> @html.Html {
  @rui.card(style=["width:min(100%,20rem);margin-inline:auto"], [
    @rui.card_header([
      @rui.skeleton(style=["width:66.667%;height:1rem"]),
      @rui.skeleton(style=["width:50%;height:1rem"]),
    ]),
    @rui.card_content(@rui.skeleton(style=["width:100%;aspect-ratio:16/9"])),
  ])
}

///|
fn foundations_skeleton_text() -> @html.Html {
  @html.div(
    style=[
      "display:flex;width:min(100%,20rem);margin-inline:auto;flex-direction:column;gap:0.5rem",
    ],
    [
      @rui.skeleton(style=["width:100%;height:1rem"]),
      @rui.skeleton(style=["width:100%;height:1rem"]),
      @rui.skeleton(style=["width:75%;height:1rem"]),
    ],
  )
}

///|
fn foundations_skeleton_form() -> @html.Html {
  @html.div(
    style=[
      "display:flex;width:min(100%,20rem);margin-inline:auto;flex-direction:column;gap:1.75rem",
    ],
    [
      @html.div(style=["display:flex;flex-direction:column;gap:0.75rem"], [
        @rui.skeleton(style=["width:5rem;height:1rem"]),
        @rui.skeleton(style=["width:100%;height:2rem"]),
      ]),
      @html.div(style=["display:flex;flex-direction:column;gap:0.75rem"], [
        @rui.skeleton(style=["width:6rem;height:1rem"]),
        @rui.skeleton(style=["width:100%;height:2rem"]),
      ]),
      @rui.skeleton(style=["width:6rem;height:2rem"]),
    ],
  )
}

///|
fn foundations_skeleton_table() -> @html.Html {
  @html.div(
    style=[
      "display:flex;width:min(100%,24rem);margin-inline:auto;flex-direction:column;gap:0.5rem",
    ],
    [
      for _row in 0..<5 => {
        @html.div(style=["display:flex;min-width:0;gap:1rem"], [
          @rui.skeleton(style=["height:1rem;min-width:0;flex:1"]),
          @rui.skeleton(style=["width:6rem;max-width:25%;height:1rem"]),
          @rui.skeleton(style=["width:5rem;max-width:25%;height:1rem"]),
        ])
      }
    ],
  )
}

///|
fn foundations_skeleton_demo() -> @html.Html {
  showcase_component_demos(
    "Skeleton",
    "Pulse placeholders preserve the shape and rhythm of content that is still loading.",
    [
      showcase_demo_section(
        "Default",
        "A circular media placeholder with two supporting text lines.",
        showcase_demo_stage(
          foundations_skeleton_default(),
          FoundationsSkeletonDefaultCode,
          variant=ShowcaseStageSurface,
        ),
      ),
      showcase_demo_section(
        "Avatar",
        "A compact avatar and identity placeholder for account lists.",
        showcase_demo_stage(
          foundations_skeleton_avatar(),
          FoundationsSkeletonAvatarCode,
          variant=ShowcaseStageSurface,
        ),
      ),
      showcase_demo_section(
        "Card",
        "Header copy and a media block preserve the dimensions of a loading card.",
        showcase_demo_stage(
          foundations_skeleton_card(),
          FoundationsSkeletonCardCode,
          variant=ShowcaseStageSurface,
        ),
      ),
      showcase_demo_section(
        "Text",
        "Three lines preserve paragraph rhythm with a shorter final line.",
        showcase_demo_stage(
          foundations_skeleton_text(),
          FoundationsSkeletonTextCode,
          variant=ShowcaseStageSurface,
        ),
      ),
      showcase_demo_section(
        "Form",
        "Labels, fields, and an action retain the spacing of a loading form.",
        showcase_demo_stage(
          foundations_skeleton_form(),
          FoundationsSkeletonFormCode,
          variant=ShowcaseStageSurface,
        ),
      ),
      showcase_demo_section(
        "Table",
        "Five rows preserve the relative widths of primary and secondary columns.",
        showcase_demo_stage(
          foundations_skeleton_table(),
          FoundationsSkeletonTableCode,
          variant=ShowcaseStageSurface,
        ),
      ),
    ],
  )
}
