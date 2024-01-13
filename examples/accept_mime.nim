import scorper_v2
import macros

const port{.intdefine.} = 8080

when isMainModule:
  proc cb() =
    var matched = false
    for mime in acceptMimes():
      case mime
      of "html":
        let headers = {"Content-Type": "text/html"}
        matched = true
        reply("Hello, World!", headers)
        break
    if not matched:
      let headers = {"Content-Type": "text/html"}
      reply("default response", headers)

  proc cb2() =
    acceptMime:
      case ext
      of "html":
        let headers = {"Content-Type": "text/html"}
        reply("Hello, World!", headers)
      else:
        let headers = {"Content-Type": "text/html"}
        reply("default response", headers)

  let server = newHttpServer(cb)
  server.start(port)
  
  let server2 = newHttpServer(cb2)
  server2.start(8081)
  joinThreads( server2.thread)
