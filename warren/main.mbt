///|
using @path {type SourcePath}

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
  #|const es = new EventSource("/__warren/events");
  #|es.addEventListener("reload", () => location.reload());

///|
async fn main {
  let cmd = @argparse.Command("warren", subcommands=[
    @argparse.Command("dev"),
    @argparse.Command("build"),
  ])
  let cli = cmd.parse()
  let cwd = @env.current_dir().unwrap()
  guard cli.subcommand is Some((subcmd, _)) else { return }
  match subcmd {
    "dev" => {
      guard @discover.discover(cwd) is Some(_) else {
        abort("Moonbit project not found in: \{cwd}")
      }

      dev_server(SourcePath::new(cwd))
    }
    "build" => abort("`warren build` is not supported yet")
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
  let s = (html[:p] + html_patch + html[p:]).to_string()
  vfs.mount("/index.html", FileContent(s))
}

///|
type Mtime = (Int64, Int)

///|
struct Model {
  event_queue : @async.Queue[DevEvent]
  cwd : SourcePath
  vfs : @vfs.VirtualFileSystem?
  dist : Dist?
}

///|
struct Dist {
  js : (SourcePath, Mtime)
  js_map : (SourcePath, Mtime)?
  public_dir : (SourcePath, Mtime, Array[String])?
} derive(Eq)

///|
enum Msg {
  DetectChanges
  FreshBuild
}

///|
async fn update(model : Model, msg : Msg) -> Model {
  async fn get_layout(cwd : SourcePath) -> Dist? {
    guard @discover.discover(cwd.to_string()) is Some(discover) else {
      log("fatal", "No projects found in \{cwd}, it could be moved.")
      None
    }
    match discover.kind {
      MoonWork(work) => {
        guard work.members.iter().find_first(x => x.root == cwd) is Some(mod) else {
          log("fatal", "Module not found in workspace")
          None
        }

        // find main package
        guard mod.packages.iter().find_first(x => x.kind is Cmd) is Some(main) else {
          log("fatal", "Main package not found for module \{mod.name}")
          None
        }

        // find dist
        let artifacts = main.artifacts
          .get((Js, Debug, Build))
          .map(dist => {
            (
              dist.iter().find_first(p => p.0.has_suffix(".js")),
              dist.iter().find_first(p => p.0.has_suffix(".js.map")),
            )
          })

        guard artifacts is Some((Some((_, js_path)), Some((_, js_map_path)))) else {
          log("warn", "Build artifacts *.js and *.js.map not found")
          None
        }

        let js = (js_path, (0L, 0))
        let js_map = Some((js_map_path, (0L, 0)))
        let assume_public_dir = mod.root.join("public")
        let public_dir = if @fs.exists(assume_public_dir.to_string()) {
          Some((assume_public_dir, (0L, 0), []))
        } else {
          None
        }
        Some({ js, js_map, public_dir })
      }
      MoonMod(mod) => {
        // find main package
        guard mod.packages.iter().find_first(x => x.kind is Cmd) is Some(main) else {
          log("fatal", "Main package not found for module \{mod.name}")
          None
        }

        // find dist
        let artifacts = main.artifacts
          .get((Js, Debug, Build))
          .map(dist => {
            (
              dist.iter().find_first(p => p.0.has_suffix(".js")),
              dist.iter().find_first(p => p.0.has_suffix(".js.map")),
            )
          })

        guard artifacts is Some((Some((_, js_path)), Some((_, js_map_path)))) else {
          log("warn", "Build artifacts *.js and *.js.map not found")
          None
        }

        let js = (js_path, (0L, 0))
        let js_map = Some((js_map_path, (0L, 0)))
        let assume_public_dir = mod.root.join("public")
        let public_dir = if @fs.exists(assume_public_dir.to_string()) {
          Some((assume_public_dir, (0L, 0), []))
        } else {
          None
        }
        Some({ js, js_map, public_dir })
      }
      _ => abort("unsupported project")
    }
  }

  async fn validate_dist(dist : Dist) -> Bool {
    let { js, public_dir, .. } = dist
    if !@fs.exists(js.0.to_string()) ||
      (public_dir is Some((dir, _, _)) && !@fs.exists(dir.to_string())) {
      false
    } else {
      true
    }
  }

  async fn check_dist(dist : Dist) -> Dist {
    let { js, public_dir, .. } = dist
    // detect changes and update
    let next_js = (js.0, @fs.mtime(js.0.to_string()))
    let next_public_dir = if public_dir is Some((path, _, _)) {
      Some((path, @fs.mtime(path.to_string()), @fs.readdir(path.to_string())))
    } else {
      None
    }

    // reload page if *.js or public/ changed
    if next_js != js || next_public_dir != public_dir {
      log("dev", "Changes detected. Reloading page...")
      model.event_queue.put(Reload)
    }
    { ..dist, js: next_js, public_dir: next_public_dir }
  }

  async fn generate_vfs(dist : Dist) -> @vfs.VirtualFileSystem {
    let vfs = @vfs.new({})
    vfs.mount("/warren_dev.js", FileContent(dev_script))
    vfs.mount("/index.js", FileMapping(dist.js.0))
    if dist.js_map is Some((p, _)) {
      vfs.mount("/index.js.map", FileMapping(p))
    }
    if dist.public_dir is Some((dir, _, files)) {
      for file in files {
        vfs.mount("/\{file}", FileMapping(dir.join(file)))
      }
      if files.contains("index.html") {
        inject_html(dir.join("index.html"), vfs)
      } else {
        vfs.mount("/index.html", FileContent(html_template))
      }
    }
    vfs
  }

  match msg {
    FreshBuild => {
      let dist = match get_layout(model.cwd) {
        None => None
        Some(x) => Some(check_dist(x))
      }
      { ..model, dist, }
    }
    DetectChanges => {
      let dist = if model.dist is Some(dist) && validate_dist(dist) {
        Some(check_dist(dist))
      } else {
        match get_layout(model.cwd) {
          None => None
          Some(x) => Some(check_dist(x))
        }
      }
      let vfs = match dist {
        None => None
        Some(x) => Some(generate_vfs(x))
      }
      { ..model, dist, vfs }
    }
  }
}

///|
async fn dev_server(dir : SourcePath) -> Unit {
  guard @fs.exists(dir.to_string()) else { abort("Dir \{dir} is no exists.") }

  let mut model = {
    event_queue: @async.Queue::new(kind=Unbounded),
    cwd: dir,
    vfs: None,
    dist: None,
  }
  model = update(model, FreshBuild)
  @async.with_task_group(group => {
    run_moon_build_watch(group, dir, target=Js, build=Debug)

    group.spawn_loop(() => {
      model = update(model, DetectChanges)
      @async.sleep(10)
    })
    serve(() => model.event_queue, () => model.vfs.unwrap_or(@vfs.new({})))
  })
}

///|
fn[A] abort(s : String) -> A {
  println(s)
  panic()
}
