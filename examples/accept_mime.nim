import scorper_v2

const port{.intdefine.} = 8080

when isMainModule:
  proc cb() {.gcsafe, nimcall, raises: [].} =
    for mime in acceptMimes():
      case mime
      of "html":
        let headers = {"Content-Type": "text/html"}
        reply("Hello, World!", headers)
        break
      else:
        discard

  let server = newHttpServer(cb)
  server.start(port)
  joinThreads(server.thread)
