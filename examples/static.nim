import scorper_v2
import std/[os, mimetypes, paths]

type ScorperCallback = proc(prefix: string){.gcsafe, nimcall, raises: [].}

when isMainModule:
  
  proc cb() {.gcsafe, nimcall, raises: [].} =
    var r = newRouter[ScorperCallback]()
    {.cast(raises: []).}:
      r.addRoute(serveStatic, "get", "/static/*$")
    let meth = getMethod()
    let uri = getUri()
    {.cast(raises: []).}:
      let url = parseUrl(uri)
    {.cast(raises: []).}:
      let matched = r.match(meth, url.path)
    if matched.success:
      let params = matched.route.params[]
      let prefix = matched.route.prefix
      matched.handler(prefix)
  echo "check " & "http://127.0.0.1:8888/static/hello_world.txt"
  let server = newHttpServer(cb)
  server.start(8888)
  joinThreads(server.thread)