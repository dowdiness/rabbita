///|
let new_project_name_placeholder = "__WARREN_PROJECT_NAME__"

///|
let default_new_project_template = "default"

///|
enum TemplateEntry {
  Dir(String, Array[TemplateEntry])
  File(String, String)
}

///|
let default_template_dir : TemplateEntry = Dir("", [
  File("moon.mod", templates.default.moon_mod),
  File("README.md", templates.default.readme_md),
  Dir("main", [
    File("moon.pkg", templates.default.main.moon_pkg),
    File("main.mbt", templates.default.main.main_mbt),
  ]),
  Dir("public", [
    File("styles.css", templates.default.public.styles_css),
    File("index.html", templates.default.public.index_html),
  ]),
])

///|
let minimized_template_dir : TemplateEntry = Dir("", [
  File("moon.mod", templates.minimized.moon_mod),
  File("moon.pkg", templates.minimized.moon_pkg),
  File("main.mbt", templates.minimized.main_mbt),
])

///|
fn render_new_project_file(content : String, project_name : String) -> String {
  content.split(new_project_name_placeholder).collect().join(project_name)
}

///|
fn is_valid_project_name(name : String) -> Bool {
  let mut valid = name != "" && name != "." && name != ".."
  let invalid_parts = [" ", "\t", "\n", "\r", "/", "\\", ":", "\"", "'"]
  for part in invalid_parts {
    if name.contains(part) {
      valid = false
    }
  }
  valid
}

///|
async fn write_new_project_file(
  root : String,
  relative_path : String,
  content : String,
) -> Unit {
  let path = Path::join(root, relative_path).to_string()
  let parent = Path::dirname(path).to_string()
  if parent != "" && parent != "." && !@fs.exists(parent) {
    @fs.mkdir(parent, permission=0o755, recursive=true)
  }
  @fs.write_file(path, content, create_mode=CreateOrTruncate, permission=0o644)
}

///|
async fn write_template_entry(
  root : String,
  parent : String,
  entry : TemplateEntry,
  project_name : String,
) -> Unit {
  match entry {
    File(name, content) => {
      let path = if parent == "" {
        name
      } else {
        Path::join(parent, name).to_string()
      }
      write_new_project_file(
        root,
        path,
        render_new_project_file(content, project_name),
      )
    }
    Dir(name, children) => {
      let dir = if name == "" {
        parent
      } else if parent == "" {
        name
      } else {
        Path::join(parent, name).to_string()
      }
      for child in children {
        write_template_entry(root, dir, child, project_name)
      }
    }
  }
}

///|
async fn new_project(dir : String, template_name : String) -> Unit {
  let target_dir = Path::resolve(dir).to_string()
  let project_name = Path::basename(target_dir).to_owned()
  let template_dir = match template_name {
    "default" => default_template_dir
    "minimized" => minimized_template_dir
    _ => {
      println(
        "Unknown template `\{template_name}`. Available templates: default, minimized.",
      )
      return
    }
  }
  guard is_valid_project_name(project_name) else {
    abort(
      "Invalid project directory name `\{project_name}`. Avoid spaces, path separators, and quotes.",
    )
  }
  guard !@fs.exists(target_dir) else {
    abort("Target path already exists: \{target_dir}")
  }

  @fs.mkdir(target_dir, permission=0o755, recursive=true)
  write_template_entry(target_dir, "", template_dir, project_name)

  println("Created Warren project in \{target_dir}")
  println("")
  println("Next steps:")
  println("  cd \{target_dir}")
  println("  warren dev")
}

///|
test "render_new_project_file replaces placeholders" {
  inspect(
    render_new_project_file("local/__WARREN_PROJECT_NAME__", "demo"),
    content="local/demo",
  )
}

///|
test "is_valid_project_name rejects empty and path-like names" {
  inspect(is_valid_project_name("demo-app"), content="true")
  inspect(is_valid_project_name(""), content="false")
  inspect(is_valid_project_name("two words"), content="false")
  inspect(is_valid_project_name("nested/path"), content="false")
}
