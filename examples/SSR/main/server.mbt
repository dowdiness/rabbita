///|
#cfg(target="native")
async fn serve_404(conn : @http.ServerConnection) -> Unit {
  conn
  ..send_response(404, "NotFound", extra_headers={ "Content-Type": "text/html" })
  ..write(b"<html><head></head><body>Page Not Found</body></html>")
  .end_response()
}

///|
#cfg(target="native")
async fn serve_file(
  conn : @http.ServerConnection,
  file_path : String,
  path~ : String,
) -> Unit {
  let file = @fs.open(file_path, mode=ReadOnly)
  defer file.close()
  let content_type = match path {
    [.., .. ".png"] => "image/png"
    [.., .. ".jpg"] | [.., .. ".jpeg"] => "image/jpeg"
    [.., .. ".html"] => "text/html"
    [.., .. ".css"] => "text/css"
    [.., .. ".js"] => "text/javascript"
    [.., .. ".mp4"] => "video/mp4"
    [.., .. ".mpv"] => "video/mpv"
    [.., .. ".mpeg"] => "video/mpeg"
    [.., .. ".mkv"] => "video/x-matroska"
    _ => "application/octet-stream"
  }
  conn
  ..send_response(200, "OK", extra_headers={ "Content-Type": content_type })
  ..write_reader(file)
  .end_response()
}

///|
#cfg(target="native")
pub async fn server_main(
  server : @http.Server,
  path~ : String,
  html~ : String,
  log? : (String) -> Unit = println,
) -> Unit {
  server.run_forever((request, _body, conn) => {
    let req_path = request.path
    guard request.meth is Get else { return }
    log("serving \{req_path}")
    if req_path == "/" {
      conn
      ..send_response(200, "OK", extra_headers={ "Content-Type": "text/html" })
      ..write(html)
      .end_response()
      return
    } else {
      let file_path = "\{path}/dist\{req_path}"
      guard req_path.contains("..") || @fs.exists(file_path) else {
        serve_404(conn)
        return
      }
      serve_file(conn, file_path, path=req_path)
    }
  })
}

///|
let path : String = match @env.args() {
  [] | [_] => "."
  [_, path, ..] => path
}

///|
#cfg(target="native")
async fn main {
  let app = @rabbita.simple_cell(model=0, update~, view~)
  let html =
    $| <!DOCTYPE html>
    $| <html lang="en">
    $| <head>
    $|     <meta charset="UTF-8">
    $|     <meta name="viewport" content="width=device-width, initial-scale=1.0">
    $|     <title>rabbita template</title>
    $|     <link rel="stylesheet" type="text/css" href="/assets/styles.css" />
    $|     <script src="/assets/main.js" type="module"></script>
    $| </head>
    $| <body>
    $|     <div id="app">
    $|       \{@rabbita.render_to_string(app)}
    $|     </div>
    $| </body>
    $| </html>
  let port = "8006"
  let server = @http.Server::new(@socket.Addr::parse("0.0.0.0:\{port}"))
  println("Listening on http://localhost:\{port} ...")
  server_main(server, path~, html~) catch {
    err => println("server terminate due to \{err}")
  }
}
