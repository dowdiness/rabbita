///|
fn target_arg(target : @path.Target) -> String {
  match target {
    Js => "js"
    Native => "native"
    Wasm => "wasm"
    WasmGC => "wasm-gc"
  }
}

///|
fn build_arg(build : @path.Build) -> String? {
  match build {
    Release => Some("--release")
    Debug => None
  }
}

///|
#cfg(not(platform="windows"))
fn shell_quote(s : String) -> String {
  let escaped = s.replace_all(old="'", new="'\"'\"'")
  "'" + escaped + "'"
}

///|
#cfg(platform="windows")
fn shell_quote(s : String) -> String {
  let escaped = s.replace_all(old="\"", new="\"\"")
  "\"" + escaped + "\""
}

///|
#borrow(command)
extern "C" fn system(command : Bytes) -> Int = "system"

///|
fn encode_c_string(s : String) -> Bytes {
  let bytes = @utf8.encode(s).to_array()
  bytes.push(b'\x00')
  Bytes::from_array(bytes)
}

///|
fn run_command(command : String) -> Int {
  let terminated = encode_c_string(command)
  system(terminated)
}

///|
async fn run_moon_build_watch(
  group : @async.TaskGroup[Unit],
  working_dir : @path.SourcePath,
  target? : @path.Target = Js,
  build? : @path.Build = Debug,
) -> Unit {
  let args = ["build", "--target", target_arg(target)]
  if build_arg(build) is Some(arg) {
    args.push(arg)
  }
  args.push("--watch")
  let command = args.join(" ")
  log("moon", "Running `moon \{command}` on \{working_dir}")

  let (reader, output) = @process.read_from_process()
  let process = @process.spawn(
    group,
    "moon",
    args,
    stdout=output,
    stderr=output,
    cwd="\{working_dir}",
    no_wait=true,
  )

  group.spawn_bg(no_wait=true, () => {
    defer reader.close()
    while reader.read_until("\n") is Some(line) {
      if line != "" {
        log("moon", line)
      }
    }
  })

  group.spawn_bg(no_wait=true, () => {
    let exit_code = process.wait()
    log("moon", "`moon build --watch` exited with code \{exit_code}")
  })
}

///|
enum DevEvent {
  Reload
}

///|
async fn serve_dev_events(
  conn : @http.ServerConnection,
  get_channel : () -> @async.Queue[DevEvent],
) -> Unit {
  conn.send_response(200, "OK", extra_headers={
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
  })
  conn.write(": connected\n\n")
  conn.flush()
  while get_channel().get() is event {
    match event {
      Reload => {
        conn.write("event: reload\n")
        conn.write("data: now\n\n")
        conn.flush()
      }
    }
  }
}

///|
async fn serve(
  port? : UInt = 0,
  get_channel : () -> @async.Queue[DevEvent],
  get_vfs : () -> @vfs.VirtualFileSystem,
) -> Unit {
  let ip = "127.0.0.1"
  let server = @http.Server::new(
    @socket.Addr::parse("\{ip}:\{port}"),
    reuse_addr=true,
  )

  let port = server.addr.port()
  log("info", "Running server on http://\{ip}:\{port}")

  server.run_forever((request, _body, conn) => {
    async fn go(path) {
      match path {
        "/" => go("/index.html")
        "/__warren/events" => serve_dev_events(conn, get_channel)
        other if get_vfs().read(other) is Some(content) => {
          let content_type = match @path.Path::extname(path) {
            ".png" => "image/png"
            ".jpg" | ".jpeg" => "image/jpeg"
            ".html" => "text/html"
            ".css" => "text/css"
            ".js" => "text/javascript"
            ".mp4" => "video/mp4"
            ".mpv" => "video/mpv"
            ".mpeg" => "video/mpeg"
            ".mkv" => "video/x-matroska"
            _ => "application/octet-stream"
          }
          log("info", "200 OK, GET \{path}")
          conn
          ..send_response(200, "OK", extra_headers={
            "Content-Type": content_type,
          })
          ..write(content)
          .end_response()
        }
        _ => {
          log("info", "404 Not Found, GET \{path}")
          conn
          ..send_response(404, "NotFound", extra_headers={
            "Content-Type": "text/plain",
          })
          ..write("\{path} Not Found")
          .end_response()
        }
      }
    }

    let path = request.path
    guard request.meth is Get else { return }
    go(path)
  })
}

///|
pub async fn copy(src~ : SourcePath, dst~ : SourcePath) -> Unit {
  let src_str = "\{src}"
  let dst_str = "\{dst}"
  guard @fs.exists(src_str) else { fail("Source path does not exist: \{src}") }
  if @fs.kind(src_str) is Directory {
    @fs.mkdir(dst_str, permission=0o755, recursive=true)
    for entry in @fs.readdir(src_str, sort=true) {
      copy(src=src.join(entry), dst=dst.join(entry))
    }
  } else {
    let parent = @path.Path::dirname(dst_str).to_string()
    if parent != "" && parent != "." && !@fs.exists(parent) {
      @fs.mkdir(parent, permission=0o755, recursive=true)
    }
    let reader = @fs.open(src_str, mode=ReadOnly)
    defer reader.close()
    let writer = @fs.open(dst_str, mode=WriteOnly, create=0o644, truncate=true)
    defer writer.close()
    writer.write_reader(reader)
  }
}
