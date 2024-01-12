import scorper_v2
import cgi, strtabs, guildenstern/[dispatcher, httpserver]

const port{.intdefine.} = 8080

proc reply*(body: string, headers: openArray[tuple[key: string, val: string]]) {.inline, gcsafe, raises: [].} =
  {.cast(raises: []).}:
    let joinedheaders = $headers.newHttpHeaders()
  reply(Http200, unsafeAddr body, unsafeAddr joinedheaders)

when isMainModule:
  proc cb() =
    let headers = {"Content-type": "text/plain"}
    reply("Hello, World!", headers)
  let server = newHttpServer(cb)
  server.start(port)
  joinThreads(server.thread)
