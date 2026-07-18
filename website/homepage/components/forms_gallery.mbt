///|
const FormsGalleryFormGridStyle : String = "display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,18rem),1fr));gap:1.25rem"

///|
const FormsGalleryChoiceStyle : String = "display:flex;align-items:center;gap:0.625rem"

///|
const FormsInputTextCode : String =
  #|let (name, set_name) = @rabbita.create_variable("Ada Lovelace")
  #|name.view(name => @html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input(
  #|        id="forms-gallery-input-name",
  #|        name="standalone-display-name",
  #|        value=name,
  #|        placeholder="Ada Lovelace",
  #|        on_input=set_name.map(value => _ => value),
  #|  ),
  #|))
  #|

///|
const FormsInputEmailCode : String =
  #|let (email, set_email) = @rabbita.create_variable("ada@example.com")
  #|email.view(email => @html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input(
  #|        id="forms-gallery-input-email",
  #|        input_type=@html.Email,
  #|        value=email,
  #|        invalid=email == "invalid",
  #|        placeholder="ada@example.com",
  #|        on_input=set_email.map(value => _ => value),
  #|  ),
  #|))
  #|

///|
const FormsInputDisabledCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.input(
  #|        id="forms-gallery-input-disabled",
  #|        value="Inherited workspace",
  #|        disabled=true,
  #|  ),
  #|)
  #|

///|
const FormsTextareaDefaultCode : String =
  #|let (note, set_note) = @rabbita.create_variable(
  #|  "Ship the first programmable workspace.",
  #|)
  #|note.view(note => @html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.textarea(
  #|      id="forms-gallery-textarea-default",
  #|      value=note,
  #|      rows=4,
  #|      placeholder="What should collaborators know?",
  #|      on_input=set_note.map(value => _ => value),
  #|  ),
  #|))
  #|

///|
const FormsTextareaInvalidCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.textarea(
  #|      id="forms-gallery-textarea-invalid",
  #|      rows=4,
  #|      invalid=true,
  #|      placeholder="Explain what failed…",
  #|  ),
  #|)
  #|

///|
const FormsTextareaDisabledCode : String =
  #|@html.div(
  #|  style=["width:min(100%,24rem);margin-inline:auto"],
  #|  @rui.textarea(
  #|      id="forms-gallery-textarea-disabled",
  #|      rows=4,
  #|      value="Managed by your organization",
  #|      disabled=true,
  #|  ),
  #|)
  #|

///|
const FormsRadioHorizontalCode : String =
  #|let (plan, set_plan) = @rabbita.create_variable("monthly")
  #|let horizontal = @rui.radio_group(
  #|  default_value="monthly",
  #|  name="forms-gallery-billing",
  #|  orientation=@rui.RadioHorizontal,
  #|  aria_label="Billing cycle",
  #|  on_value_change=set_plan.map(value => _ => value),
  #|  scope => @html.div(
  #|    style=["display:flex;flex-wrap:wrap;align-items:center;gap:0.75rem"],
  #|    [
  #|      @html.div(style=["display:flex;align-items:center;gap:0.625rem"], [
  #|        @rui.radio_group_item(
  #|          scope~,
  #|          value="monthly",
  #|          id="forms-gallery-monthly",
  #|          aria_label="Monthly",
  #|        ),
  #|        @rui.label(for_="forms-gallery-monthly", "Monthly"),
  #|      ]),
  #|      @html.div(style=["display:flex;align-items:center;gap:0.625rem"], [
  #|        @rui.radio_group_item(
  #|          scope~,
  #|          value="annual",
  #|          id="forms-gallery-annual",
  #|          aria_label="Annual",
  #|        ),
  #|        @rui.label(for_="forms-gallery-annual", "Annual"),
  #|      ]),
  #|    ],
  #|  ),
  #|)
  #|plan.view2(horizontal, (plan, horizontal_html) => @html.div(
  #|  style=["display:flex;width:min(100%,32rem);margin-inline:auto;flex-direction:column;gap:1rem"],
  #|  [
  #|    horizontal_html,
  #|    @html.output(
  #|      style=["color:var(--rui-muted-foreground);font-size:0.8125rem;line-height:1.35"],
  #|      "Billing value: \{plan}",
  #|    ),
  #|  ],
  #|))
  #|

///|
const FormsRadioVerticalCode : String =
  #|let vertical = @rui.radio_group(
  #|  default_value="automatic",
  #|  name="forms-gallery-sync",
  #|  orientation=@rui.RadioVertical,
  #|  aria_label="Sync strategy",
  #|  scope => @html.div(
  #|    style=["display:flex;flex-direction:column;gap:1rem", "gap:0.625rem"],
  #|    [
  #|      @html.div(style=["display:flex;align-items:center;gap:0.625rem"], [
  #|        @rui.radio_group_item(
  #|          scope~,
  #|          value="automatic",
  #|          id="forms-gallery-sync-automatic",
  #|          aria_label="Automatic sync",
  #|        ),
  #|        @rui.label(for_="forms-gallery-sync-automatic", "Automatic"),
  #|      ]),
  #|      @html.div(style=["display:flex;align-items:center;gap:0.625rem"], [
  #|        @rui.radio_group_item(
  #|          scope~,
  #|          value="manual",
  #|          id="forms-gallery-sync-manual",
  #|          aria_label="Manual sync",
  #|        ),
  #|        @rui.label(for_="forms-gallery-sync-manual", "Manual"),
  #|      ]),
  #|    ],
  #|  ),
  #|)
  #|vertical.view(vertical_html => @html.div(
  #|  style=["width:min(100%,32rem);margin-inline:auto"],
  #|  vertical_html,
  #|))
  #|

///|
fn forms_input_component(
  text_html : @html.Html,
  email_html : @html.Html,
  disabled_html : @html.Html,
) -> @html.Html {
  showcase_component_demos(
    "Input",
    "Text, email, validation, and disabled variants use the native input while sharing the same control surface.",
    [
      showcase_demo_section(
        "Text",
        "A parent-controlled text value remains live inside its own example.",
        showcase_demo_stage(
          text_html,
          FormsInputTextCode,
          variant=ShowcaseStageSurface,
          stage_style="--rui-showcase-stage-min-height:13rem",
        ),
      ),
      showcase_demo_section(
        "Email",
        "Type “invalid” to reveal validation styling without replacing native editing.",
        showcase_demo_stage(
          email_html,
          FormsInputEmailCode,
          variant=ShowcaseStageSurface,
          stage_style="--rui-showcase-stage-min-height:13rem",
        ),
      ),
      showcase_demo_section(
        "Disabled",
        "An inherited value stays readable but unavailable.",
        showcase_demo_stage(
          disabled_html,
          FormsInputDisabledCode,
          variant=ShowcaseStagePlain,
          stage_style="--rui-showcase-stage-min-height:13rem",
        ),
      ),
    ],
  )
}

///|
fn forms_textarea_component(
  default_html : @html.Html,
  invalid_html : @html.Html,
  disabled_html : @html.Html,
) -> @html.Html {
  showcase_component_demos(
    "Textarea",
    "Default, validation, and disabled variants preserve native multiline editing and resizing behavior.",
    [
      showcase_demo_section(
        "Default",
        "A parent-controlled launch note remains editable and resizable.",
        showcase_demo_stage(
          default_html,
          FormsTextareaDefaultCode,
          variant=ShowcaseStagePlain,
          stage_style="--rui-showcase-stage-min-height:16rem",
        ),
      ),
      showcase_demo_section(
        "Invalid",
        "Validation styling keeps the multiline input editable.",
        showcase_demo_stage(
          invalid_html,
          FormsTextareaInvalidCode,
          variant=ShowcaseStagePlain,
          stage_style="--rui-showcase-stage-min-height:16rem",
        ),
      ),
      showcase_demo_section(
        "Disabled",
        "Managed copy remains readable without becoming editable.",
        showcase_demo_stage(
          disabled_html,
          FormsTextareaDisabledCode,
          variant=ShowcaseStageSurface,
          stage_style="--rui-showcase-stage-min-height:16rem",
        ),
      ),
    ],
  )
}

///|
fn forms_radio_component(
  horizontal_html : @html.Html,
  vertical_html : @html.Html,
) -> @html.Html {
  showcase_component_demos(
    "Radio Group",
    "Horizontal and vertical orientations retain component-owned selection and native radio semantics.",
    [
      showcase_demo_section(
        "Horizontal",
        "Choose a billing cycle and observe the component-owned selection value.",
        showcase_demo_stage(
          horizontal_html,
          FormsRadioHorizontalCode,
          variant=ShowcaseStageSurface,
          stage_style="--rui-showcase-stage-min-height:15rem",
        ),
      ),
      showcase_demo_section(
        "Vertical",
        "Stack the same native radio semantics for a sync strategy.",
        showcase_demo_stage(
          vertical_html,
          FormsRadioVerticalCode,
          variant=ShowcaseStageSurface,
          stage_style="--rui-showcase-stage-min-height:15rem",
        ),
      ),
    ],
  )
}

///|
const FormsSliderDefaultCode : String =
  #|let (density_value, set_density) = @rabbita.create_variable(64)
  #|let density_slider = @rui.slider(
  #|  id="forms-gallery-density",
  #|  default_value=64,
  #|  min=0,
  #|  max=100,
  #|  step=4,
  #|  aria_label="Interface density",
  #|  on_value_change=set_density.map(value => _ => value),
  #|)
  #|density_value.view2(density_slider, (density_value, density_html) => {
  #|  @html.div(
  #|    style=["display:flex;width:min(100%,32rem);margin-inline:auto;flex-direction:column;gap:1rem"],
  #|    [
  #|      @html.div(
  #|        style=["display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:1rem"],
  #|        [
  #|          @rui.label(for_="forms-gallery-density", "Interface density"),
  #|          @html.output(
  #|            style=["color:var(--rui-muted-foreground);font-size:0.8125rem;line-height:1.35"],
  #|            "\{density_value}%",
  #|          ),
  #|        ],
  #|      ),
  #|      density_html,
  #|    ],
  #|  )
  #|})
  #|

///|
const FormsSliderRangeCode : String =
  #|let range_slider = @rui.slider_values(
  #|  id="forms-gallery-budget-range",
  #|  default_values=[28, 72],
  #|  min=0,
  #|  max=100,
  #|  step=4,
  #|  large_step=12,
  #|  min_steps_between_values=3,
  #|  aria_label="Budget range",
  #|)
  #|range_slider.view(range_html => {
  #|  @html.div(
  #|    style=["width:min(100%,32rem);margin-inline:auto"],
  #|    range_html,
  #|  )
  #|})
  #|

///|
const FormsSliderVerticalCode : String =
  #|let vertical_slider = @rui.slider(
  #|  id="forms-gallery-volume",
  #|  default_value=68,
  #|  orientation=@rui.Vertical,
  #|  aria_label="Preview volume",
  #|  style=["height:10rem"],
  #|)
  #|vertical_slider.view(vertical_html => {
  #|  @html.div(
  #|    style=["display:flex;min-height:12rem;align-items:center;justify-content:center"],
  #|    vertical_html,
  #|  )
  #|})
  #|

///|
fn forms_slider_component(
  default_html : @html.Html,
  range_html : @html.Html,
  vertical_html : @html.Html,
) -> @html.Html {
  showcase_component_demos(
    "Slider",
    "Single-value, range, and vertical controls remain independently interactive.",
    [
      showcase_demo_section(
        "Default",
        "A single thumb updates the interface density value.",
        showcase_demo_stage(
          default_html,
          FormsSliderDefaultCode,
          variant=ShowcaseStagePlain,
          stage_style="--rui-showcase-stage-min-height:15rem",
        ),
      ),
      showcase_demo_section(
        "Range",
        "Two constrained thumbs select a bounded budget range.",
        showcase_demo_stage(
          range_html,
          FormsSliderRangeCode,
          variant=ShowcaseStagePlain,
          stage_style="--rui-showcase-stage-min-height:15rem",
        ),
      ),
      showcase_demo_section(
        "Vertical",
        "The same keyboard and pointer interaction works on a vertical track.",
        showcase_demo_stage(
          vertical_html,
          FormsSliderVerticalCode,
          variant=ShowcaseStagePlain,
          stage_style="--rui-showcase-stage-min-height:20rem",
        ),
      ),
    ],
  )
}
