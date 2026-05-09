///|
using @html {a, button, div, iframe, li, nothing, option, pre, select, span, ul}

///|
using @rabbita {type Cmd, type Dispatch, type Html}

///|
struct Diagnostic {
  level : String
  path : String
  line : Int
  column : Int
  end_line : Int
  end_column : Int
  message : String
}

///|
enum Msg {
  AssetsReady(Result[@js.Value, Error])
  SelectTab(SourceTab)
  FocusDiagnostic(Diagnostic)
  TogglePackageMenu
  ClosePackageMenu
  ExampleChanged(String)
  ExampleFileLoaded(Int, ExampleAsset, Result[String, Error])
  MbtChanged(String)
  HtmlChanged(String)
  CssChanged(String)
  MoonPkgChanged(String)
  RunRequested
  Run(Int)
  CompileReady(Int, Result[@js.Value, Error])
  Reset
}

///|
enum SourceTab {
  Mbt
  Html
  Css
  MoonPkg
} derive(Eq)

///|
enum ExampleAsset {
  RepoSource(Int)
  RepoCss
  RepoMoonPkg
}

///|
struct Model {
  active_tab : SourceTab
  mbt : String
  html : String
  css : String
  moon_pkg : String
  compiled_js : String?
  asset_status : String
  asset_packages : Array[String]
  package_menu_open : Bool
  status : String
  log : String
  diagnostics : Array[Diagnostic]
  compiling : Bool
  run_id : Int
  example_id : String
  example_load : ExampleLoad?
}

///|
struct Example {
  id : String
  label : String
  mbt : String
  html : String
  css : String
  moon_pkg : String
  load_from_repo : Bool
  repo_sources : Array[String]
  repo_css : String
  repo_moon_pkg : String
}

///|
struct LoadedExample {
  mbt : String
  html : String
  css : String
  moon_pkg : String
}

///|
struct ExampleLoad {
  token : Int
  example_id : String
  sources : Array[String?]
  css : String?
  moon_pkg : String?
}

///|
let examples : Array[Example] = [
  {
    id: "counter",
    label: "Counter",
    mbt: default_mbt,
    html: default_html,
    css: default_css,
    moon_pkg: default_moon_pkg,
    load_from_repo: false,
    repo_sources: [],
    repo_css: "",
    repo_moon_pkg: "",
  },
  {
    id: "grocery",
    label: "Grocery List",
    mbt: grocery_mbt,
    html: default_html,
    css: grocery_css,
    moon_pkg: default_moon_pkg,
    load_from_repo: false,
    repo_sources: [],
    repo_css: "",
    repo_moon_pkg: "",
  },
  {
    id: "sokobank",
    label: "Sokoban",
    mbt: "",
    html: default_html,
    css: "",
    moon_pkg: "",
    load_from_repo: true,
    repo_sources: ["repo-examples/sokobank/main/main.mbt"],
    repo_css: "repo-examples/sokobank/public/styles.css",
    repo_moon_pkg: "repo-examples/sokobank/main/moon.pkg",
  },
  {
    id: "animation",
    label: "Animation",
    mbt: "",
    html: default_html,
    css: "",
    moon_pkg: "",
    load_from_repo: true,
    repo_sources: [
      "repo-examples/animation/main/client.mbt", "repo-examples/animation/main/logo_animation.mbt",
      "repo-examples/animation/main/animation_tab.mbt",
    ],
    repo_css: "repo-examples/animation/public/styles.css",
    repo_moon_pkg: "repo-examples/animation/main/moon.pkg",
  },
]

///|
fn initial_model() -> Model {
  {
    active_tab: Mbt,
    mbt: read_source("mbt", default_mbt),
    html: initial_html(),
    css: read_source("css", default_css),
    moon_pkg: read_source("moon_pkg", default_moon_pkg),
    compiled_js: None,
    asset_status: "Loading compiler assets",
    asset_packages: [],
    package_menu_open: false,
    status: "Idle",
    log: "",
    diagnostics: [],
    compiling: false,
    run_id: 0,
    example_id: read_source("example", "counter"),
    example_load: None,
  }
}

///|
fn initial_html() -> String {
  let html = read_source("html", default_html)
  if html.trim().to_owned() == "<div id=\"app\"></div>" {
    default_html
  } else {
    html
  }
}

///|
fn split_lines(source : String) -> Array[String] {
  let out = Array::new()
  for line in source.split("\n") {
    let value = line.trim().to_owned()
    if value != "" {
      out.push(value)
    }
  }
  out
}

///|
fn diagnostics_from_result(value : @js.Value) -> Array[Diagnostic] {
  let count = js_diagnostic_count(value, "diagnostics")
  Array::makei(count, i => {
    level: js_diagnostic_string(value, "diagnostics", i, "level"),
    path: js_diagnostic_string(value, "diagnostics", i, "path"),
    line: js_diagnostic_int(value, "diagnostics", i, "line"),
    column: js_diagnostic_int(value, "diagnostics", i, "column"),
    end_line: js_diagnostic_int(value, "diagnostics", i, "endLine"),
    end_column: js_diagnostic_int(value, "diagnostics", i, "endColumn"),
    message: js_diagnostic_string(value, "diagnostics", i, "message"),
  })
}

///|
fn persist_cmd(model : Model) -> Cmd {
  @rabbita.attempt(_ => @rabbita.none, async fn() {
    save_source_promise(
      model.example_id,
      model.mbt,
      model.html,
      model.css,
      model.moon_pkg,
    ).wait()
  })
}

///|
fn clear_storage_cmd() -> Cmd {
  @rabbita.attempt(_ => @rabbita.none, async fn() {
    clear_source_promise().wait()
  })
}

///|
fn render_cmd(html : String, css : String, js : String) -> Cmd {
  @rabbita.effect(async fn() noraise { render_preview(html, css, js) })
}

///|
fn load_assets_cmd(dispatch : Dispatch[Msg]) -> Cmd {
  @rabbita.attempt(result => dispatch(AssetsReady(result)), async fn() {
    load_assets_promise().wait()
  })
}

///|
fn basename(path : String) -> String {
  match path.rev_find("/") {
    Some(index) => path[index + 1:].to_owned()
    None => path
  }
}

///|
fn join_blocks(items : Array[String]) -> String {
  let out = StringBuilder::new()
  for index, item in items {
    if index > 0 {
      out.write_string("\n\n")
    }
    out.write_string(item)
  }
  out.to_string()
}

///|
fn new_example_load(token : Int, example : Example) -> ExampleLoad {
  {
    token,
    example_id: example.id,
    sources: Array::makei(example.repo_sources.length(), _ => None),
    css: None,
    moon_pkg: None,
  }
}

///|
fn update_example_load(
  load : ExampleLoad,
  asset : ExampleAsset,
  body : String,
) -> ExampleLoad {
  match asset {
    RepoSource(index) => {
      let sources = load.sources.copy()
      sources.set(index, Some(body))
      { ..load, sources, }
    }
    RepoCss => { ..load, css: Some(body) }
    RepoMoonPkg => { ..load, moon_pkg: Some(body) }
  }
}

///|
fn loaded_example_from_load(load : ExampleLoad) -> LoadedExample? {
  guard load.css is Some(css) else { None }
  guard load.moon_pkg is Some(moon_pkg) else { None }
  let example = example_by_id(load.example_id)
  let parts : Array[String] = []
  for index, source in load.sources {
    guard source is Some(source) else { return None }
    let path = example.repo_sources[index]
    parts.push("// \{example.label} / \{basename(path)}\n\{source}")
  }
  Some({
    mbt: join_blocks(parts),
    html: html_document(example.label),
    css,
    moon_pkg,
  })
}

///|
fn load_example_cmd(
  dispatch : Dispatch[Msg],
  token : Int,
  example : Example,
) -> Cmd {
  let cmds : Array[Cmd] = []
  for index, path in example.repo_sources {
    cmds.push(
      @http.get(path).expect_text(result => {
        dispatch(ExampleFileLoaded(token, RepoSource(index), result))
      }),
    )
  }
  cmds.push(
    @http.get(example.repo_css).expect_text(result => {
      dispatch(ExampleFileLoaded(token, RepoCss, result))
    }),
  )
  cmds.push(
    @http.get(example.repo_moon_pkg).expect_text(result => {
      dispatch(ExampleFileLoaded(token, RepoMoonPkg, result))
    }),
  )
  @rabbita.batch(cmds)
}

///|
fn compile_cmd(
  dispatch : Dispatch[Msg],
  token : Int,
  source : String,
  moon_pkg : String,
) -> Cmd {
  @rabbita.attempt(result => dispatch(CompileReady(token, result)), async fn() {
    compile_mbt_promise(source, moon_pkg).wait()
  })
}

///|
fn preview_refresh_cmd(model : Model) -> Cmd {
  match model.compiled_js {
    Some(js) => render_cmd(model.html, model.css, js)
    None => @rabbita.none
  }
}

///|
fn editor_sync_cmd(dispatch : Dispatch[Msg], model : Model) -> Cmd {
  let active = model.active_tab
  sync_code_editor(
    "code-editor-host",
    tab_id(active),
    tab_value(model),
    tab_lang(active),
    tab_input(dispatch, active),
  )
}

///|
fn editor_focus_diagnostic_cmd(
  dispatch : Dispatch[Msg],
  model : Model,
  diagnostic : Diagnostic,
) -> Cmd {
  focus_code_editor_range(
    "code-editor-host",
    tab_id(Mbt),
    model.mbt,
    tab_lang(Mbt),
    tab_input(dispatch, Mbt),
    diagnostic.line,
    diagnostic.column,
    diagnostic.end_line,
    diagnostic.end_column,
  )
}

///|
fn update(dispatch : Dispatch[Msg], msg : Msg, model : Model) -> (Cmd, Model) {
  match msg {
    SelectTab(tab) => {
      let next = { ..model, active_tab: tab }
      (editor_sync_cmd(dispatch, next), next)
    }
    FocusDiagnostic(diagnostic) => {
      let next = { ..model, active_tab: Mbt }
      (editor_focus_diagnostic_cmd(dispatch, next, diagnostic), next)
    }
    TogglePackageMenu =>
      (@rabbita.none, { ..model, package_menu_open: !model.package_menu_open })
    ClosePackageMenu => (@rabbita.none, { ..model, package_menu_open: false })
    ExampleChanged(id) => {
      let example = example_by_id(id)
      let token = model.run_id + 1
      if example.load_from_repo {
        let next = {
          ..model,
          example_id: example.id,
          compiled_js: None,
          status: "Loading example",
          log: "",
          diagnostics: [],
          compiling: false,
          run_id: token,
          example_load: Some(new_example_load(token, example)),
        }
        (load_example_cmd(dispatch, token, example), next)
      } else {
        let next = {
          ..model,
          example_id: example.id,
          mbt: example.mbt,
          html: example.html,
          css: example.css,
          moon_pkg: example.moon_pkg,
          compiled_js: None,
          status: "Pending",
          log: "",
          diagnostics: [],
          compiling: false,
          run_id: token,
          example_load: None,
        }
        (
          @rabbita.batch([
            persist_cmd(next),
            dispatch(Run(token)),
            editor_sync_cmd(dispatch, next),
          ]),
          next,
        )
      }
    }
    ExampleFileLoaded(token, asset, result) =>
      if token != model.run_id {
        (@rabbita.none, model)
      } else {
        match result {
          Ok(body) =>
            match model.example_load {
              Some(load) if load.token == token => {
                let load = update_example_load(load, asset, body)
                match loaded_example_from_load(load) {
                  Some(loaded) => {
                    let next = {
                      ..model,
                      mbt: loaded.mbt,
                      html: loaded.html,
                      css: loaded.css,
                      moon_pkg: loaded.moon_pkg,
                      compiled_js: None,
                      status: "Pending",
                      log: "",
                      diagnostics: [],
                      compiling: false,
                      example_load: None,
                    }
                    (
                      @rabbita.batch([
                        persist_cmd(next),
                        dispatch(Run(token)),
                        editor_sync_cmd(dispatch, next),
                      ]),
                      next,
                    )
                  }
                  None => (@rabbita.none, { ..model, example_load: Some(load) })
                }
              }
              _ => (@rabbita.none, model)
            }
          Err(error) =>
            (
              @rabbita.none,
              {
                ..model,
                status: "Example missing",
                log: "\{error}",
                diagnostics: [],
                compiling: false,
                example_load: None,
              },
            )
        }
      }
    AssetsReady(result) =>
      match result {
        Ok(value) =>
          if js_result_ok(value) {
            let count = js_result_int(value, "count")
            let packages = split_lines(js_result_string(value, "packages"))
            let token = model.run_id + 1
            let next = {
              ..model,
              asset_status: "\{count} packages available",
              asset_packages: packages,
              status: "Pending",
              diagnostics: [],
              run_id: token,
            }
            (dispatch(Run(token)), next)
          } else {
            let message = js_result_string(value, "error")
            (
              @rabbita.none,
              {
                ..model,
                asset_status: "Compiler assets missing",
                asset_packages: [],
                status: "Assets missing",
                log: message,
                diagnostics: [],
              },
            )
          }
        Err(error) =>
          (
            @rabbita.none,
            {
              ..model,
              asset_status: "Compiler assets missing",
              asset_packages: [],
              status: "Assets missing",
              log: "\{error}",
              diagnostics: [],
            },
          )
      }
    CompileReady(token, result) =>
      if token != model.run_id {
        (@rabbita.none, model)
      } else {
        match result {
          Ok(value) =>
            if js_result_ok(value) {
              let js = js_result_string(value, "js")
              let elapsed = js_result_int(value, "elapsed")
              let next = {
                ..model,
                compiled_js: Some(js),
                status: "Rendered in \{elapsed}ms",
                log: "",
                diagnostics: [],
                compiling: false,
              }
              (render_cmd(next.html, next.css, js), next)
            } else {
              let message = js_result_string(value, "error")
              let diagnostics = diagnostics_from_result(value)
              (
                @rabbita.none,
                {
                  ..model,
                  status: "Compile failed",
                  log: message,
                  diagnostics,
                  compiling: false,
                },
              )
            }
          Err(error) =>
            (
              @rabbita.none,
              {
                ..model,
                status: "Compile failed",
                log: "\{error}",
                diagnostics: [],
                compiling: false,
              },
            )
        }
      }
    MbtChanged(source) => {
      let token = model.run_id + 1
      let next = {
        ..model,
        mbt: source,
        status: "Pending",
        log: "",
        diagnostics: [],
        compiling: false,
        run_id: token,
        example_load: None,
      }
      (
        @rabbita.batch([
          persist_cmd(next),
          @rabbita.delay(dispatch(Run(token)), 650),
        ]),
        next,
      )
    }
    HtmlChanged(source) => {
      let next = { ..model, html: source, example_load: None }
      (@rabbita.batch([persist_cmd(next), preview_refresh_cmd(next)]), next)
    }
    CssChanged(source) => {
      let next = { ..model, css: source, example_load: None }
      (@rabbita.batch([persist_cmd(next), preview_refresh_cmd(next)]), next)
    }
    MoonPkgChanged(source) => {
      let token = model.run_id + 1
      let next = {
        ..model,
        moon_pkg: source,
        status: "Pending",
        log: "",
        diagnostics: [],
        compiling: false,
        run_id: token,
        example_load: None,
      }
      (
        @rabbita.batch([
          persist_cmd(next),
          @rabbita.delay(dispatch(Run(token)), 650),
        ]),
        next,
      )
    }
    RunRequested => {
      let token = model.run_id + 1
      let next = {
        ..model,
        status: "Pending",
        log: "",
        diagnostics: [],
        run_id: token,
        example_load: None,
      }
      (dispatch(Run(token)), next)
    }
    Run(token) =>
      if token != model.run_id {
        (@rabbita.none, model)
      } else {
        let next = {
          ..model,
          status: "Compiling",
          compiling: true,
          log: "",
          diagnostics: [],
        }
        (compile_cmd(dispatch, token, model.mbt, model.moon_pkg), next)
      }
    Reset => {
      let token = model.run_id + 1
      let example = example_by_id(model.example_id)
      if example.load_from_repo {
        let next = {
          ..model,
          compiled_js: model.compiled_js,
          status: "Loading example",
          log: "",
          diagnostics: [],
          compiling: false,
          run_id: token,
          example_load: Some(new_example_load(token, example)),
        }
        (
          @rabbita.batch([
            clear_storage_cmd(),
            load_example_cmd(dispatch, token, example),
          ]),
          next,
        )
      } else {
        let next = {
          active_tab: model.active_tab,
          mbt: example.mbt,
          html: example.html,
          css: example.css,
          moon_pkg: example.moon_pkg,
          compiled_js: model.compiled_js,
          asset_status: model.asset_status,
          asset_packages: model.asset_packages,
          package_menu_open: false,
          status: "Pending",
          log: "",
          diagnostics: [],
          compiling: false,
          run_id: token,
          example_id: example.id,
          example_load: None,
        }
        (
          @rabbita.batch([
            clear_storage_cmd(),
            preview_refresh_cmd(next),
            dispatch(Run(token)),
            editor_sync_cmd(dispatch, next),
          ]),
          next,
        )
      }
    }
  }
}

///|
fn tab_title(tab : SourceTab) -> String {
  match tab {
    Mbt => "main.mbt"
    Html => "index.html"
    Css => "style.css"
    MoonPkg => "moon.pkg"
  }
}

///|
fn tab_id(tab : SourceTab) -> String {
  match tab {
    Mbt => "mbt-editor"
    Html => "html-editor"
    Css => "css-editor"
    MoonPkg => "moon-pkg-editor"
  }
}

///|
fn tab_lang(tab : SourceTab) -> String {
  match tab {
    Mbt => "moonbit"
    Html => "html"
    Css => "css"
    MoonPkg => "moonbit"
  }
}

///|
fn tab_value(model : Model) -> String {
  match model.active_tab {
    Mbt => model.mbt
    Html => model.html
    Css => model.css
    MoonPkg => model.moon_pkg
  }
}

///|
fn example_by_id(id : String) -> Example {
  let mut selected = examples[0]
  for example in examples {
    if example.id == id {
      selected = example
    }
  }
  selected
}

///|
fn tab_input(dispatch : Dispatch[Msg], tab : SourceTab) -> (String) -> Cmd {
  match tab {
    Mbt => s => dispatch(MbtChanged(s))
    Html => s => dispatch(HtmlChanged(s))
    Css => s => dispatch(CssChanged(s))
    MoonPkg => s => dispatch(MoonPkgChanged(s))
  }
}

///|
fn rebuild_button_state(model : Model) -> String {
  if model.compiling || model.status == "Compiling" {
    "building"
  } else if model.status == "Pending" {
    "pending"
  } else {
    ""
  }
}

///|
fn rebuild_button_class(model : Model) -> String {
  let state = rebuild_button_state(model)
  if state == "" {
    "plain-button primary rebuild-button"
  } else {
    "plain-button primary rebuild-button \{state}"
  }
}

///|
fn rebuild_button_icon(model : Model) -> Html {
  if rebuild_button_state(model) == "" {
    let line_attrs = @svg.Attrs::build()
      .stroke_linecap("round")
      .stroke_linejoin("round")
    @svg.svg(
      class="button-icon rebuild-icon",
      width=14,
      height=14,
      view_box="0 0 24 24",
      [
        @svg.path(
          d="M21 12a9 9 0 1 1-2.64-6.36",
          fill="none",
          stroke="currentColor",
          stroke_width=2,
          attrs=line_attrs,
        ),
        @svg.polyline(
          points=[(21, 3), (21, 9), (15, 9)],
          fill="none",
          stroke="currentColor",
          stroke_width=2,
          stroke_linecap="round",
          attrs=@svg.Attrs::build().stroke_linejoin("round"),
        ),
      ],
    )
  } else {
    span(class="button-icon status-spinner", "")
  }
}

///|
fn rebuild_button_text(model : Model) -> String {
  match rebuild_button_state(model) {
    "building" => "Building"
    "pending" => "Pending"
    _ => "Rebuild"
  }
}

///|
fn tab_button(
  dispatch : Dispatch[Msg],
  active : SourceTab,
  tab : SourceTab,
) -> Html {
  let selected = active == tab
  let class_name = if selected { "tab-button selected" } else { "tab-button" }
  button(class=class_name, on_click=dispatch(SelectTab(tab)), tab_title(tab))
}

///|
fn example_select(dispatch : Dispatch[Msg], model : Model) -> Html {
  select(
    id="example-select",
    class="example-select",
    on_change=value => dispatch(ExampleChanged(value)),
    examples.map(example => {
      option(
        value=example.id,
        selected=model.example_id == example.id,
        example.label,
      )
    }),
  )
}

///|
fn package_docs_url(pkg : String) -> String {
  "https://mooncakes.io/docs/\{pkg}"
}

///|
fn package_menu(dispatch : Dispatch[Msg], model : Model) -> Html {
  if model.asset_packages.is_empty() {
    span(class="asset-status", model.asset_status)
  } else {
    let class_name = if model.package_menu_open {
      "package-menu open"
    } else {
      "package-menu"
    }
    div(class=class_name, [
      button(
        type_="button",
        class="package-trigger",
        attrs=@html.Attrs::build().on_blur(_ => {
          @rabbita.delay(dispatch(ClosePackageMenu), 120)
        }),
        on_click=dispatch(TogglePackageMenu),
        [
          span(class="package-label", "Packages"),
          span(class="package-count", "\{model.asset_packages.length()}"),
        ],
      ),
      if model.package_menu_open {
        div(class="package-popover", [
          div(class="package-heading", model.asset_status),
          ul(
            class="package-list",
            model.asset_packages.map(pkg => {
              li(class="package-item", [
                a(
                  class="package-link",
                  href=package_docs_url(pkg),
                  target=Blank,
                  rel="noreferrer",
                  escape=true,
                  pkg,
                ),
              ])
            }),
          ),
        ])
      } else {
        nothing
      },
    ])
  }
}

///|
fn code_panel(_dispatch : Dispatch[Msg], _model : Model) -> Html {
  div(class="code-panel", [
    div(id="code-editor-host", class="code-editor-host", nothing),
  ])
}

///|
fn show_diagnostics(model : Model) -> Bool {
  (
    model.status == "Compile failed" ||
    model.status == "Assets missing" ||
    model.status == "Example missing"
  ) &&
  model.log != ""
}

///|
fn diagnostic_location(diagnostic : Diagnostic) -> String {
  if diagnostic.line > 0 && diagnostic.column > 0 {
    "\{diagnostic.path}:\{diagnostic.line}:\{diagnostic.column}"
  } else {
    diagnostic.path
  }
}

///|
fn diagnostic_row(dispatch : Dispatch[Msg], diagnostic : Diagnostic) -> Html {
  button(
    class="diagnostic-item \{diagnostic.level}",
    on_click=dispatch(FocusDiagnostic(diagnostic)),
    [
      span(class="diagnostic-location", diagnostic_location(diagnostic)),
      span(class="diagnostic-message", diagnostic.message),
    ],
  )
}

///|
fn diagnostics_output(dispatch : Dispatch[Msg], model : Model) -> Html {
  div(
    id="diagnostics-output",
    class="diagnostics-output",
    if model.diagnostics.is_empty() {
      [pre(class="diagnostics-plain", model.log)]
    } else {
      model.diagnostics.map(diagnostic => diagnostic_row(dispatch, diagnostic))
    },
  )
}

///|
fn result_body(dispatch : Dispatch[Msg], model : Model) -> Html {
  if show_diagnostics(model) {
    diagnostics_output(dispatch, model)
  } else {
    iframe(
      id="preview-frame",
      title="Compiled Rabbita result",
      sandbox="allow-scripts allow-forms allow-modals allow-popups",
    )
  }
}

///|
fn result_overlay(model : Model) -> Html {
  let state = rebuild_button_state(model)
  let class_name = if state == "" {
    "result-overlay"
  } else {
    "result-overlay visible \{state}"
  }
  div(class=class_name, nothing)
}

///|
fn view(dispatch : Dispatch[Msg], model : Model) -> Html {
  div(class="shell", [
    div(class="workbench", [
      div(class="top-bar editor-status", [
        div(class="bar-group", [
          example_select(dispatch, model),
          package_menu(dispatch, model),
        ]),
        div(class="bar-group", [
          button(
            class="plain-button",
            id="reset-button",
            on_click=dispatch(Reset),
            "Reset",
          ),
          button(
            id="rebuild-button",
            class=rebuild_button_class(model),
            disabled=model.compiling,
            on_click=dispatch(RunRequested),
            [rebuild_button_icon(model), span(rebuild_button_text(model))],
          ),
        ]),
      ]),
      div(class="tab-strip", [
        tab_button(dispatch, model.active_tab, Mbt),
        tab_button(dispatch, model.active_tab, Html),
        tab_button(dispatch, model.active_tab, Css),
        tab_button(dispatch, model.active_tab, MoonPkg),
      ]),
      code_panel(dispatch, model),
    ]),
    div(class="result", [result_body(dispatch, model), result_overlay(model)]),
  ])
}

///|
fn main {
  let model = initial_model()
  let (dispatch, app) = @rabbita.cell_with_dispatch(model~, update~, view~)
  @rabbita.new(app)
  ..with_init(
    @rabbita.batch([load_assets_cmd(dispatch), editor_sync_cmd(dispatch, model)]),
  )
  .mount("app")
}
