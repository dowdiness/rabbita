///|
priv struct NamedEntry {
  name : String
  package_dir : SourcePath
}

///|
priv struct BuildEntry {
  name : String?
  package_dir : SourcePath
}

///|
fn entry_output_filename(name : String?) -> String {
  match name {
    None => "index.js"
    Some(name) => name + ".js"
  }
}

///|
fn is_safe_entry_name(name : String) -> Bool {
  name != "" &&
  name != "index" &&
  name.all(c => {
    c.is_ascii_alphabetic() || c.is_ascii_digit() || c == '-' || c == '_'
  })
}

///|
fn parse_named_entries(
  values : ArrayView[String],
  cwd : SourcePath,
) -> Result[Array[NamedEntry], String] {
  let entries : Array[NamedEntry] = []
  for raw in values {
    let separator = raw.find("=")
    guard separator is Some(separator) else {
      return Err("expected NAME=PACKAGE")
    }
    guard separator > 0 && separator + 1 < raw.length() else {
      return Err("expected non-empty NAME and PACKAGE")
    }
    let name = raw[:separator].to_owned()
    let package_dir = raw[separator + 1:].to_owned()
    guard is_safe_entry_name(name) else {
      return Err("unsafe entry name `\{name}`")
    }
    guard !entries.any(entry => entry.name == name) else {
      return Err("duplicate entry name `\{name}`")
    }
    let resolved_package_dir = Path::join(
      source_path_to_string(cwd),
      package_dir,
    ).to_string()
    entries.push({ name, package_dir: SourcePath::new(resolved_package_dir) })
  }
  Ok(entries)
}

///|
fn build_entry_for_page(package_dir : SourcePath) -> BuildEntry {
  { name: None, package_dir }
}

///|
fn build_entry_for_named(entry : NamedEntry) -> BuildEntry {
  { name: Some(entry.name), package_dir: entry.package_dir }
}

///|
fn all_build_entries(
  main_pkg_dir : SourcePath,
  auxiliary_entries : ArrayView[NamedEntry],
) -> Array[BuildEntry] {
  let entries = [build_entry_for_page(main_pkg_dir)]
  for entry in auxiliary_entries {
    entries.push(build_entry_for_named(entry))
  }
  entries
}

///|
fn entry_target_dir(
  root : SourcePath,
  entry : BuildEntry,
  has_auxiliary_entries : Bool,
) -> SourcePath {
  match entry.name {
    None => if has_auxiliary_entries { root.join("__page") } else { root }
    Some(name) => root.join("__aux-\{name}")
  }
}

///|
fn release_js_artifact(
  js_paths : Array[String],
  build_dir : String,
) -> SourcePath {
  match js_paths {
    [js_path] => SourcePath::new(js_path)
    [] => abort("Release JS artifact not found under \{build_dir}")
    _ =>
      abort(
        "Found multiple release JS artifacts: \{to_repr(js_paths)}. Use `warren build path/to/main/package/dir` to choose one entry.",
      )
  }
}

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
async fn run_release_build(
  main_pkg_dir : SourcePath,
  target_dir : SourcePath,
) -> Unit {
  let args = [
    "build",
    source_path_to_string(main_pkg_dir),
    "--target",
    "js",
    "--release",
    "--target-dir",
    source_path_to_string(target_dir),
  ]
  let command = args.join(" ")
  log("build", "Running `moon \{command}`")
  let exit_code = @process.run("moon", args) catch {
    err => abort("Failed to run `moon build`: \{err}")
  }
  guard exit_code == 0 else {
    abort("`moon \{command}` exited with code \{exit_code}")
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
      create_mode=CreateOrTruncate,
      permission=0o644,
    )
  } else {
    let has_stylesheet = @fs.exists(
      source_path_to_string(dist_dir.join("styles.css")),
    )
    @fs.write_file(
      index_str,
      default_build_html(has_stylesheet),
      create_mode=CreateOrTruncate,
      permission=0o644,
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
async fn build_release_entry(
  root_target_dir : SourcePath,
  entry : BuildEntry,
  has_auxiliary_entries : Bool,
) -> SourcePath {
  let target_dir = entry_target_dir(
    root_target_dir, entry, has_auxiliary_entries,
  )
  ensure_clean_dir(target_dir)
  run_release_build(entry.package_dir, target_dir)
  let build_dir = target_dir.join("js/release/build")
  release_js_artifact(
    find_js_in(source_path_to_string(build_dir)),
    source_path_to_string(build_dir),
  )
}

///|
async fn build_project_with_entries(
  main_pkg_dir : SourcePath,
  auxiliary_entries : ArrayView[NamedEntry],
  dist_dir? : SourcePath,
) -> Unit {
  let main_pkg_dir_str = source_path_to_string(main_pkg_dir)
  let mod_root = if Path::basename(main_pkg_dir_str) == "main" {
    SourcePath::new(Path::dirname(main_pkg_dir_str).to_string())
  } else {
    main_pkg_dir
  }
  let target_dir = SourcePath::new(@fs.tmpdir(prefix="warren"))
  let dist_dir = dist_dir.unwrap_or(mod_root.join("dist"))
  let public_dir = mod_root.join("public")
  let has_auxiliary_entries = !auxiliary_entries.is_empty()
  let entries = all_build_entries(main_pkg_dir, auxiliary_entries)
  let release_entries : Array[(String?, SourcePath)] = []
  for entry in entries {
    let release_js = build_release_entry(
      target_dir, entry, has_auxiliary_entries,
    )
    release_entries.push((entry.name, release_js))
  }

  ensure_clean_dir(dist_dir)
  if @fs.exists(source_path_to_string(public_dir)) {
    guard @fs.kind(source_path_to_string(public_dir)) is Directory else {
      abort("`public` exists but is not a directory: \{public_dir}")
    }
    copy_dir_contents(public_dir, dist_dir)
  }

  for release_entry in release_entries {
    minify_or_copy_js(
      release_entry.1,
      dist_dir.join(entry_output_filename(release_entry.0)),
      mod_root,
    )
  }
  write_index_html(dist_dir)

  log("build", "Build output written to \{dist_dir}")
}

///|
pub async fn build_project(
  main_pkg_dir : SourcePath,
  dist_dir? : SourcePath,
) -> Unit {
  build_project_with_entries(main_pkg_dir, [], dist_dir?)
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
