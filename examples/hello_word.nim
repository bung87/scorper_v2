import scorper_v2

const port{.intdefine.} = 8080

when isMainModule:
  proc cb() =
    let headers = {"Content-Type": "text/plain"}
    reply("Hello, World!", headers)
  let server = newHttpServer(cb)
  server.start(port)
  joinThreads(server.thread)
