///|
let build_entry_script =
  #|    <script src="./index.js" type="module"></script>

///|
fn source_path_to_string(path : SourcePath) -> String {
  "\{path}"
}

///|
fn has_build_entry_script(html : String) -> Bool {
  html.contains("src=\"./index.js\"") ||
  html.contains("src='./index.js'") ||
  html.contains("./index.js")
}

///|
fn inject_build_entry_script(html : String) -> String {
  guard !has_build_entry_script(html) else { html }
  let patch = build_entry_script + "\n"
  match html.rev_find("</head>") {
    Some(index) => html[:index].to_owned() + patch + html[index:].to_owned()
    None =>
      match html.rev_find("</body>") {
        Some(index) => html[:index].to_owned() + patch + html[index:].to_owned()
        None =>
          match html.rev_find("</html>") {
            Some(index) =>
              html[:index].to_owned() + patch + html[index:].to_owned()
            None =>
              if html.has_suffix("\n") {
                html + patch
              } else {
                html + "\n" + patch
              }
          }
      }
  }
}

///|
fn default_build_html(has_stylesheet : Bool) -> String {
  let stylesheet = if has_stylesheet {
    (
      #|    <link rel="stylesheet" type="text/css" href="./styles.css"></link>
    )
  } else {
    ""
  }
  (
    $|<!DOCTYPE html>
    $|<html lang="en">
    $|<head>
    $|    <meta charset="UTF-8">
    $|    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    $|    <title>warren build</title>
    $|\{stylesheet}
    $|\{build_entry_script}
    $|</head>
    $|<body>
    $|    <div id="app"></div>
    $|</body>
    $|</html>
  )
}

///|
fn is_within_path(root : SourcePath, path : SourcePath) -> Bool {
  let relative = path.relative(root)
  relative == "." ||
  relative == "" ||
  !(relative == ".." ||
  relative.has_prefix("../") ||
  relative.has_prefix("..\\"))
}

///|
fn select_workspace_member(
  work : @discover.MoonWork,
  cwd : SourcePath,
) -> @discover.MoonMod? {
  let mut selected = None
  let mut selected_len = -1
  for mod in work.members {
    if is_within_path(mod.root, cwd) {
      let root_len = source_path_to_string(mod.root).length()
      if root_len > selected_len {
        selected = Some(mod)
        selected_len = root_len
      }
    }
  }
  selected
}

///|
async fn resolve_module(cwd : SourcePath) -> @discover.MoonMod {
  guard @discover.discover(source_path_to_string(cwd)) is Some(discover) else {
    abort("Moonbit project not found in: \{cwd}")
  }

  match discover.kind {
    MoonWork(work) => {
      let mod = match select_workspace_member(work, cwd) {
        Some(mod) => mod
        None =>
          abort(
            "Current directory is not inside a MoonBit workspace member: \{cwd}",
          )
      }
      mod
    }
    MoonMod(mod) => mod
    _ => abort("`warren build` only supports MoonBit modules")
  }
}

///|
fn cmd_packages(mod : @discover.MoonMod) -> Array[@discover.MoonPkg] {
  let mains = []
  for pkg in mod.packages {
    if pkg.kind is Cmd {
      mains.push(pkg)
    }
  }
  mains
}

///|
fn require_single_main_package(mod : @discover.MoonMod) -> @discover.MoonPkg {
  let mains = cmd_packages(mod)
  match mains.length() {
    0 => abort("Main package not found for module \{mod.name}")
    1 => mains[0]
    _ => {
      let names = []
      for pkg in mains {
        names.push(source_path_to_string(pkg.root))
      }
      let joined_names = names.join(", ")
      abort(
        "Multiple main packages found for module \{mod.name}: \{joined_names}",
      )
    }
  }
}

///|
fn find_release_js(pkg : @discover.MoonPkg) -> SourcePath {
  guard pkg.artifacts.get((Js, Release, Build)) is Some(artifacts) else {
    abort("Release JS build artifacts not found for package \{pkg.name}")
  }
  guard artifacts.iter().find_first(entry => entry.0.has_suffix(".js"))
    is Some((_, path)) else {
    abort("Release JS artifact not found for package \{pkg.name}")
  }
  path
}

///|
async fn ensure_clean_dir(path : SourcePath) -> Unit {
  let path_str = source_path_to_string(path)
  if @fs.exists(path_str) {
    match @fs.kind(path_str) {
      Directory => @fs.rmdir(path_str, recursive=true)
      _ => @fs.remove(path_str)
    }
  }
  @fs.mkdir(path_str, permission=0o755, recursive=true) catch {
    err => {
      guard @fs.exists(path_str) && @fs.kind(path_str) is Directory else {
        raise err
      }
    }
  }
}

///|
async fn copy_dir_contents(src : SourcePath, dst : SourcePath) -> Unit {
  for entry in @fs.readdir(source_path_to_string(src), sort=true) {
    copy(src=src.join(entry), dst=dst.join(entry))
  }
}

///|
async fn run_release_build(mod_root : SourcePath) -> Unit {
  let args = ["build", "--target", "js", "--release"]
  let command = args.join(" ")
  log("build", "Running `moon \{command}` on \{mod_root}")
  let exit_code = try
    @process.run("moon", args, cwd=source_path_to_string(mod_root))
  catch {
    err => abort("Failed to run `moon build`: \{err}")
  } noraise {
    code => code
  }
  guard exit_code == 0 else {
    abort("`moon build --target js --release` exited with code \{exit_code}")
  }
}

///|
async fn has_command(cmd : String) -> Bool {
  try @process.collect_stdout(cmd, ["--version"]) catch {
    _ => false
  } noraise {
    (0, _) => true
    _ => false
  }
}

///|
async fn run_minifier(
  cmd : String,
  args : Array[String],
  cwd : SourcePath,
  label : String,
) -> Bool {
  log("build", "Minifying JS with \{label}")
  try @process.run(cmd, args, cwd=source_path_to_string(cwd)) catch {
    err => {
      log("warn", "\{label} failed: \{err}. Falling back to release JS")
      false
    }
  } noraise {
    0 => true
    code => {
      log(
        "warn",
        "\{label} exited with code \{code}, falling back to release JS",
      )
      false
    }
  }
}

///|
async fn write_index_html(dist_dir : SourcePath) -> Unit {
  let index_path = dist_dir.join("index.html")
  let index_str = source_path_to_string(index_path)
  if @fs.exists(index_str) {
    let html = @fs.read_file(index_str).text()
    @fs.write_file(
      index_str,
      inject_build_entry_script(html),
      create=0o644,
      truncate=true,
    )
  } else {
    let has_stylesheet = @fs.exists(
      source_path_to_string(dist_dir.join("styles.css")),
    )
    @fs.write_file(
      index_str,
      default_build_html(has_stylesheet),
      create=0o644,
      truncate=true,
    )
  }
}

///|
async fn minify_or_copy_js(
  src : SourcePath,
  dst : SourcePath,
  mod_root : SourcePath,
) -> Unit {
  let src_str = source_path_to_string(src)
  let dst_str = source_path_to_string(dst)
  let terser_args = [
    src_str, "-c", "toplevel=true", "-m", "toplevel=true", "-o", dst_str,
  ]

  if has_command("terser") {
    guard !run_minifier("terser", terser_args, mod_root, "terser") else {
      return
    }
    copy(src~, dst~)
    return
  }

  if has_command("node") && has_command("npm") {
    guard !run_minifier(
      "npm",
      ["exec", "--yes", "terser", "--", ..terser_args],
      mod_root,
      "npm exec terser",
    ) else {
      return
    }
    copy(src~, dst~)
    return
  }

  log(
    "warn", "terser not found and node/npm unavailable. Using Moon release JS without extra minification.",
  )
  copy(src~, dst~)
}

///|
pub async fn build_project(cwd : SourcePath) -> Unit {
  let mod = resolve_module(cwd)
  ignore(require_single_main_package(mod))

  let mod_root = mod.root
  let dist_dir = mod_root.join("dist")
  let public_dir = mod_root.join("public")

  run_release_build(mod_root)

  let built_mod = resolve_module(mod_root)
  let release_js = find_release_js(require_single_main_package(built_mod))

  ensure_clean_dir(dist_dir)
  if @fs.exists(source_path_to_string(public_dir)) {
    guard @fs.kind(source_path_to_string(public_dir)) is Directory else {
      abort("`public` exists but is not a directory: \{public_dir}")
    }
    copy_dir_contents(public_dir, dist_dir)
  }

  minify_or_copy_js(release_js, dist_dir.join("index.js"), mod_root)
  write_index_html(dist_dir)

  log("build", "Build output written to \{dist_dir}")
}

///|
async test "inject_build_entry_script inserts before head" {
  let html =
    $|<html>
    $|<head>
    $|</head>
    $|<body></body>
    $|</html>
  inspect(
    inject_build_entry_script(html),
    content=(
      $|<html>
      $|<head>
      $|    <script src="./index.js" type="module"></script>
      $|</head>
      $|<body></body>
      $|</html>
    ),
  )
}

///|
async test "inject_build_entry_script does not duplicate existing entry" {
  let html =
    $|<html>
    $|<body>
    $|    <script src="./index.js" type="module"></script>
    $|</body>
    $|</html>
  inspect(inject_build_entry_script(html), content=html)
}

///|
async test "default_build_html optionally links stylesheet" {
  inspect(default_build_html(true).contains("./styles.css"), content="true")
  inspect(default_build_html(false).contains("./styles.css"), content="false")
}
