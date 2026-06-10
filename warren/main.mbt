///|
using @path {type SourcePath, type Path}

///|
using @devhub {type BroadcastMsg, type Devhub}

///|
using @string {parse_int}

///|
let html_template =
  $|<!DOCTYPE html>
  $|<html lang="en">
  $|<head>
  $|    <meta charset="UTF-8">
  $|    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  $|    <title>warren dev</title>
  $|\{html_patch}
  $|</head>
  $|<body>
  $|    <div id="app"></div>
  $|</body>
  $|</html>

///|
let html_patch =
  #|<script src="/index.js" type="module"></script>
  #|<script src="/warren_dev.js"></script>
  #|<link rel="stylesheet" type="text/css" href="/styles.css"></link>

///|
let dev_script =
  #|let warrenSocket;
  #|function connectWarrenDevSocket() {
  #|  const protocol = location.protocol === "https:" ? "wss:" : "ws:";
  #|  warrenSocket = new WebSocket(`${protocol}//${location.host}/__warren/events`);
  #|  warrenSocket.addEventListener("message", event => {
  #|    if (event.data === "reload") location.reload();
  #|  });
  #|  warrenSocket.addEventListener("close", () => {
  #|    setTimeout(connectWarrenDevSocket, 1000);
  #|  });
  #|}
  #|connectWarrenDevSocket();

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
        ],
        about="Build a release static site into ./dist by default.",
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
      let target_dir = @fs.tmpdir(prefix="warren")
      dev_server(main_pkg_dir~, target_dir~, public_dir~, port~)
    }
    "build" => {
      let cwd_main = Path::join(cwd, "main").to_string()
      let main_pkg_dir = match submatches.values.get("main-package-dir") {
        Some([path]) => Path::resolve(path).to_string()
        _ if @fs.exists(cwd_main) => cwd_main
        _ => cwd
      }
      let dist_dir = match submatches.values.get("dist") {
        Some([path]) => Path::resolve(path).to_string()
        _ => Path::join(cwd, "dist").to_string()
      }
      build_project(
        SourcePath::new(main_pkg_dir),
        dist_dir=SourcePath::new(dist_dir),
      )
    }
    _ => ()
  }
}

///|
async fn inject_html(path : SourcePath, vfs : @vfs.VirtualFileSystem) -> Unit {
  let html = @fs.read_file(path.to_string()).text()
  let tag = match html.rev_find("</head>") {
    None => html.rev_find("</html>")
    x => x
  }
  guard tag is Some(p) else {
    log("warn", "No </head> or </html> tag in index.html")
  }
  let s = (html[:p] + html_patch + html[p:]).to_owned()
  vfs.mount("/index.html", FileContent(s))
}

///|
async fn dev_server(
  main_pkg_dir~ : String,
  target_dir~ : String,
  public_dir~ : String?,
  port~ : UInt,
) -> Unit {
  let watcher = @fs.Watcher(main_pkg_dir, ignored_paths=path => {
    path.contains(".mooncakes") ||
    path.contains("node_modules") ||
    path.contains("_build")
  })

  let vfs = @vfs.new({})
  if public_dir is Some(dir) {
    vfs.mount("/", DirectoryMapping(SourcePath::new(dir)))
    let files = @fs.readdir(dir)
    if files.contains("index.html") {
      inject_html(
        SourcePath::new(Path::join(dir, "index.html").to_string()),
        vfs,
      )
    } else {
      vfs.mount("/index.html", FileContent(html_template))
    }
  }
  vfs.mount("/warren_dev.js", FileContent(dev_script))

  @async.with_task_group <| group => {
    let hub = Devhub(port, vfs)
    group.spawn_bg(no_wait=true, allow_failure=true, () => hub.run_forever())
    log("info", "Running server on http://127.0.0.1:\{hub.port()}")

    while true {
      let (reader, out) = @process.read_from_process()
      let (stdin, close_stdin) = @process.write_to_process()
      close_stdin.close()
      @fs.rmdir(target_dir, recursive=true)
      let code = @process.run(
        "moon",
        ["build", main_pkg_dir, "--target", "js", "--target-dir", target_dir],
        stdin~,
        stdout=out,
        stderr=out,
      )

      defer reader.close()
      while reader.read_until("\n") is Some(line) {
        if line != "" {
          log("moon", line)
        }
      }

      if code == 0 {
        log("warren", "moon build succeed at \{main_pkg_dir}.")
        let js_paths = find_js_in(
          Path::join(target_dir, "js/debug/build").to_string(),
        )
        guard js_paths is [js_path] else {
          log("error", "found multiple entries: \{to_repr(js_paths)}")
          log(
            "info", "Use `warren dev path/to/main/package/dir` to choose one entry.",
          )
        }

        let basename = Path::basename(js_path)
        let js_map_path = Path::dirname(js_path)
          .join("\{basename}.map")
          .to_string()

        if @fs.exists(js_map_path) {
          vfs.mount("index.js.map", FileMapping(SourcePath::new(js_map_path)))
        } else {
          vfs.unmount("index.js.map")
        }

        vfs.mount("index.js", FileMapping(SourcePath::new(js_path)))
        // debug(vfs)
        hub.broadcast(BroadcastMsg::Reload)
        log("warren", "Changes detected. Reloading...")
      } else {
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
