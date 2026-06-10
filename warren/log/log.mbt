///|
pub fn log(tag : String, msg : String) -> Unit {
  let display_tag = if tag.length() < 7 {
    let prefix = " ".repeat(7 - tag.length())
    "\{prefix}[\{tag}]"
  } else {
    "[\{tag}]"
  }
  let use_color = match @env.get_env_var("NO_COLOR") {
    Some(_) => false
    None =>
      match @env.get_env_var("FORCE_COLOR") {
        Some("0") => false
        Some(_) => true
        None =>
          match @env.get_env_var("TERM") {
            Some("dumb") | None => false
            Some(_) => true
          }
      }
  }

  let tag_color = match tag {
    "error" | "err" | "fatal" => "\u001b[31m"
    "info" => "\u001b[37m"
    "warn" | "warning" => "\u001b[33m"
    "debug" => "\u001b[34m"
    "dev" => "\u001b[36m"
    _ => "\u001b[32m"
  }
  let now = @env.now()
  let total_minutes = now / 60000UL
  let minutes = (total_minutes % 60UL).to_int()
  let hours = (total_minutes / 60UL % 24UL).to_int()
  let hh = if hours < 10 { "0\{hours}" } else { hours.to_string() }
  let mm = if minutes < 10 { "0\{minutes}" } else { minutes.to_string() }
  let time = "\{hh}:\{mm}"
  if use_color {
    let reset = "\u001b[0m"
    let display_msg = if tag == "info" {
      "\u001b[37m\{msg}\{reset}"
    } else {
      msg
    }
    println(
      "\u001b[90m\{time}\{reset} \{tag_color}\{display_tag}\{reset}: \{display_msg}",
    )
  } else {
    println("\{time} \{display_tag}: \{msg}")
  }
}
