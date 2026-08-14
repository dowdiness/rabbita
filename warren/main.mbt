///|
using @path {type SourcePath, type Path}

///|
using @devhub {type Devhub}

///|
using @string {parse_int}

///|
let shell_html_template =
  $|<!DOCTYPE html>
  $|<html lang="en">
  $|<head>
  $|    <meta charset="UTF-8">
  $|    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  $|    <title>warren dev</title>
  $|    <script src="/warren_devtool.js" type="module"></script>
  $|    <link rel="stylesheet" type="text/css" href="/warren_devtool.css"></link>
  $|</head>
  $|<body>
  $|    <div id="warren-devtool"></div>
  $|</body>
  $|</html>

///|
let app_html_template =
  $|<!DOCTYPE html>
  $|<html lang="en">
  $|<head>
  $|    <meta charset="UTF-8">
  $|    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  $|    <title>warren preview</title>
  $|</head>
  $|<body>
  $|    <div id="app"></div>
  $|</body>
  $|</html>

///|
let preview_base_patch =
  #|<base href="/">

///|
let preview_entry_script_patch =
  #|<script src="/index.js" type="module"></script>

///|
let preview_stylesheet_patch =
  #|<link rel="stylesheet" type="text/css" href="/styles.css"></link>

///|
let direct_client_patch =
  #|<script src="/__warren/direct.js" type="module"></script>

///|
let direct_client_js =
  #|function connect() {
  #|  const protocol = location.protocol === "https:" ? "wss:" : "ws:";
  #|  const socket = new WebSocket(`${protocol}//${location.host}/__warren/events`);
  #|  socket.addEventListener("message", event => {
  #|    if (event.data === "reload") {
  #|      location.reload();
  #|    }
  #|  });
  #|  socket.addEventListener("close", () => {
  #|    setTimeout(connect, 1000);
  #|  });
  #|}
  #|connect();

///|
async fn main {
  let cli = @argparse.Command(
    "warren",
    subcommands=[
      Command(
        "dev",
        positionals=[
          PositionArg(
            "main-package-dir",
            about="Main package directory. Defaults to ./main when present, otherwise the current directory.",
          ),
        ],
        options=[
          OptionArg(
            "public-dir",
            about="Static files directory. Defaults to ./public when present.",
          ),
          OptionArg("port", about="Local preview server port. Default: 4300."),
          OptionArg(
            "entry",
            about="Auxiliary entry in NAME=PACKAGE form. May be repeated.",
            action=Append,
          ),
        ],
        flags=[
          FlagArg(
            "direct",
            about="Serve the application as the top-level page without the Warren devtool iframe.",
          ),
        ],
        about="Start a local preview server with live reload.",
      ),
      Command(
        "build",
        positionals=[
          PositionArg(
            "main-package-dir",
            about="Main package directory to build. Defaults to ./main when present, otherwise the current directory.",
          ),
        ],
        options=[
          OptionArg("dist", about="Build output directory. Default: ./dist."),
          OptionArg(
            "entry",
            about="Auxiliary entry in NAME=PACKAGE form. May be repeated.",
            action=Append,
          ),
        ],
        about="Build a release static site into ./dist by default.",
      ),
      Command(
        "new",
        positionals=[
          PositionArg(
            "dir_name",
            about="Directory name for the new Warren project.",
          ),
        ],
        options=[
          OptionArg(
            "template",
            about="Project template to use. Default: default. Available: default, minimized.",
          ),
        ],
        about="Create a minimal Rabbita project.",
      ),
    ],
    about="Preview and build MoonBit web applications.",
  ).parse()
  let cwd = @env.current_dir().unwrap()
  guard cli.subcommand is Some((subcmd, submatches)) else { return }
  match subcmd {
    "dev" => {
      let cwd_main = Path::join(cwd, "main").to_string()
      let main_pkg_dir = match submatches.values.get("main-package-dir") {
        Some([path]) => Path::resolve(path).to_string()
        _ if @fs.exists(cwd_main) => cwd_main
        _ => cwd
      }
      let auxiliary_entries = match submatches.values.get("entry") {
        Some(values) =>
          match parse_named_entries(values, SourcePath::new(cwd)) {
            Ok(entries) => entries
            Err(message) => abort("Invalid --entry value: \{message}")
          }
        None => []
      }
      let cwd_public = Path::join(cwd, "public").to_string()
      let public_dir = match submatches.values.get("public-dir") {
        Some([path]) => Some(Path::resolve(path).to_string())
        _ if @fs.exists(cwd_public) => Some(cwd_public)
        _ => None
      }
      let port = match submatches.values.get("port") {
        Some([raw]) => {
          let port = parse_int(raw) catch {
            _ =>
              abort(
                "Invalid --port value `\{raw}`. Expected a number from 1 to 65535.",
              )
          }

          guard port > 0 && port <= 65535 else {
            abort(
              "Invalid --port value `\{raw}`. Expected a number from 1 to 65535.",
            )
          }

          port.reinterpret_as_uint()
        }
        _ => 4300U
      }
      let direct = submatches.flags.get("direct") is Some(true)
      let target_dir = @fs.tmpdir(prefix="warren")
      dev_server(
        main_pkg_dir~,
        target_dir~,
        public_dir~,
        auxiliary_entries~,
        watch_root=cwd,
        port~,
        direct~,
      )
    }
    "build" => {
      let cwd_main = Path::join(cwd, "main").to_string()
      let main_pkg_dir = match submatches.values.get("main-package-dir") {
        Some([path]) => Path::resolve(path).to_string()
        _ if @fs.exists(cwd_main) => cwd_main
        _ => cwd
      }
      let auxiliary_entries = match submatches.values.get("entry") {
        Some(values) =>
          match parse_named_entries(values, SourcePath::new(cwd)) {
            Ok(entries) => entries
            Err(message) => abort("Invalid --entry value: \{message}")
          }
        None => []
      }
      let dist_dir = match submatches.values.get("dist") {
        Some([path]) => Path::resolve(path).to_string()
        _ => Path::join(cwd, "dist").to_string()
      }
      build_project_with_entries(
        SourcePath::new(main_pkg_dir),
        auxiliary_entries,
        dist_dir=SourcePath::new(dist_dir),
      )
    }
    "new" =>
      match submatches.values.get("dir_name") {
        Some([dir]) => {
          let template = match submatches.values.get("template") {
            Some([name]) => name
            _ => default_new_project_template
          }
          new_project(dir, template)
        }
        _ => println("Usage: warren new <dir_name> [--template <template>]")
      }
    _ => ()
  }
}

///|
fn inject_preview_assets(html : String) -> String {
  let html = inject_preview_base(html)
  let patch = preview_assets_for(html)
  inject_assets(html, patch)
}

///|
fn inject_direct_assets(html : String) -> String {
  let html = inject_preview_base(html)
  let patch = preview_assets_for(html) + direct_client_for(html)
  inject_assets(html, patch)
}

///|
fn inject_assets(html : String, patch : String) -> String {
  guard patch != "" else { html }
  let tag = match html.rev_find("</head>") {
    None => html.rev_find("</html>")
    x => x
  }
  match tag {
    Some(p) => (html[:p] + patch + html[p:]).to_owned()
    None => {
      log("warn", "No </head> or </html> tag in index.html")
      if html.has_suffix("\n") {
        html + patch
      } else {
        html + "\n" + patch
      }
    }
  }
}

///|
fn direct_client_for(html : String) -> String {
  if html.contains("/__warren/direct.js") {
    ""
  } else {
    direct_client_patch + "\n"
  }
}

///|
fn inject_preview_base(html : String) -> String {
  guard !html.contains("<base ") else { html }
  let head_end = match html.find("<head>") {
    Some(p) => Some(p + "<head>".length())
    None => None
  }
  match head_end {
    Some(p) => (html[:p] + "\n" + preview_base_patch + html[p:]).to_owned()
    None => preview_base_patch + "\n" + html
  }
}

///|
fn preview_assets_for(html : String) -> String {
  let script = if html.contains("index.js") {
    ""
  } else {
    preview_entry_script_patch + "\n"
  }
  let stylesheet = if html.contains("styles.css") {
    ""
  } else {
    preview_stylesheet_patch + "\n"
  }
  script + stylesheet
}

///|
test "inject_preview_assets puts base before relative assets" {
  let html =
    $|<html>
    $|<head>
    $|    <link rel="stylesheet" type="text/css" href="./styles.css"></link>
    $|    <script src="./index.js" type="module"></script>
    $|</head>
    $|<body></body>
    $|</html>
  inspect(
    inject_preview_assets(html),
    content=(
      $|<html>
      $|<head>
      $|<base href="/">
      $|    <link rel="stylesheet" type="text/css" href="./styles.css"></link>
      $|    <script src="./index.js" type="module"></script>
      $|</head>
      $|<body></body>
      $|</html>
    ),
  )
}

///|
fn build_failure_diagnostics(output : String, code : Int) -> String {
  let output = output.trim().to_owned()
  if output == "" {
    "moon build exited with code \{code}."
  } else {
    output + "\n\nmoon build exited with code \{code}."
  }
}

///|
async fn mount_dev_entry(
  vfs : @vfs.VirtualFileSystem,
  root_target_dir : SourcePath,
  entry : BuildEntry,
  has_auxiliary_entries : Bool,
) -> Bool {
  let target_dir = entry_target_dir(
    root_target_dir, entry, has_auxiliary_entries,
  )
  let build_dir = target_dir.join("js/debug/build")
  let js_paths = find_js_in(source_path_to_string(build_dir))
  match js_paths {
    [js_path] => {
      let output_filename = entry_output_filename(entry.name)
      let basename = Path::basename(js_path)
      let js_map_path = Path::dirname(js_path)
        .join("\{basename}.map")
        .to_string()
      let map_filename = output_filename + ".map"
      if @fs.exists(js_map_path) {
        vfs.mount(map_filename, FileMapping(SourcePath::new(js_map_path)))
      } else {
        vfs.unmount(map_filename)
      }
      vfs.mount(output_filename, FileMapping(SourcePath::new(js_path)))
      true
    }
    _ => {
      match entry.name {
        None => {
          log("error", "found multiple entries: \{to_repr(js_paths)}")
          log(
            "info", "Use `warren dev path/to/main/package/dir` to choose one entry.",
          )
        }
        Some(name) =>
          log(
            "error",
            "found multiple JS artifacts for `\{name}`: \{to_repr(js_paths)}",
          )
      }
      false
    }
  }
}

///|
async fn dev_server(
  main_pkg_dir~ : String,
  target_dir~ : String,
  public_dir~ : String?,
  auxiliary_entries~ : Array[NamedEntry],
  watch_root~ : String,
  port~ : UInt,
  direct~ : Bool,
) -> Unit {
  let watch_path = if auxiliary_entries.is_empty() {
    main_pkg_dir
  } else {
    watch_root
  }
  let watcher = @fs.Watcher(watch_path, ignored_paths=path => {
    path.contains(".mooncakes") ||
    path.contains("node_modules") ||
    path.contains("_build")
  })

  let vfs = @vfs.new(Map([]))
  let app_html = match public_dir {
    Some(dir) => {
      vfs.mount("/", DirectoryMapping(SourcePath::new(dir)))
      let files = @fs.readdir(dir)
      if files.contains("index.html") {
        @fs.read_file(Path::join(dir, "index.html").to_string()).text()
      } else {
        app_html_template
      }
    }
    None => app_html_template
  }
  if direct {
    vfs.mount("/index.html", FileContent(inject_direct_assets(app_html)))
    vfs.mount("/__warren/direct.js", FileContent(direct_client_js))
  } else {
    vfs.mount(
      "/__warren/preview/index.html",
      FileContent(inject_preview_assets(app_html)),
    )
    vfs.mount("/index.html", FileContent(shell_html_template))
    vfs.mount("/warren_devtool.js", FileContent(embbed_devtool_js))
    vfs.mount("/warren_devtool.css", FileContent(embbed_devtool_css))
  }
  let root_target_dir = SourcePath::new(target_dir)
  let entries = all_build_entries(
    SourcePath::new(main_pkg_dir),
    auxiliary_entries,
  )
  let has_auxiliary_entries = !auxiliary_entries.is_empty()

  @async.with_task_group <| group => {
    let html_fallback_path = if direct { Some("/index.html") } else { None }
    let hub = Devhub(port, vfs, html_fallback_path?)
    group.spawn_bg(no_wait=true, allow_failure=true, () => hub.run_forever())
    log("info", "Running server on http://127.0.0.1:\{hub.port()}")

    while true {
      @fs.rmdir(target_dir, recursive=true)
      hub.broadcast(Building)
      log("warren", "Building...")

      let diagnostics = StringBuilder::new()
      let code = @async.with_task_group <| build_group => {
        let mut code = 0
        for entry in entries {
          if code == 0 {
            let entry_target_dir = entry_target_dir(
              root_target_dir, entry, has_auxiliary_entries,
            )
            let entry_target_dir_str = source_path_to_string(entry_target_dir)
            let (reader, out) = @process.read_from_process()
            let (stdin, close_stdin) = @process.write_to_process()
            close_stdin.close()
            let exit_code = build_group.spawn(() => {
              @process.run(
                "moon",
                [
                  "build",
                  source_path_to_string(entry.package_dir),
                  "--target",
                  "js",
                  "--target-dir",
                  entry_target_dir_str,
                ],
                stdin~,
                stdout=out,
                stderr=out,
              )
            })

            while reader.read_until("\n") is Some(line) {
              if line != "" {
                diagnostics.write_string(line)
                diagnostics.write_string("\n")
                log("moon", line)
              }
            }
            reader.close()
            code = exit_code.wait()
          }
        }
        code
      }

      if code == 0 {
        log("warren", "moon build succeed at \{main_pkg_dir}.")
        let mut mount_ok = true
        for entry in entries {
          if !mount_dev_entry(
              vfs, root_target_dir, entry, has_auxiliary_entries,
            ) {
            mount_ok = false
          }
        }
        if mount_ok {
          hub.broadcast(Reload)
          log("warren", "Changes detected. Reloading...")
        } else {
          hub.broadcast(
            BuildFailed(
              "Warren expected exactly one JS artifact for every entry.",
            ),
          )
          log(
            "error", "Warren expected exactly one JS artifact for every entry.",
          )
        }
      } else {
        hub.broadcast(
          BuildFailed(build_failure_diagnostics(diagnostics.to_string(), code)),
        )
        log("error", "moon exited with code \{code}.")
      }

      watcher.wait_any()
    }
  }
}

///|
async fn find_js_in(dir : String) -> Array[String] {
  async fn collect_js_in(dir : String, js_paths : Array[String]) -> Unit {
    guard @fs.kind(dir) is Directory else { return }
    let handle = @fs.opendir(dir)
    defer handle.close()
    while handle.next() is Some(entry) {
      let path = Path::join(dir, entry.name).to_string()
      if entry.is_dir {
        collect_js_in(path, js_paths)
      } else if entry.name.has_suffix(".js") {
        js_paths.push(path)
      }
    }
  }

  let js_paths = []
  guard @fs.exists(dir) else { js_paths }
  collect_js_in(dir, js_paths)
  js_paths
}

///|
fn[A] abort(s : String) -> A {
  println(s)
  panic()
}
