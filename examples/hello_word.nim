import scorper_v2
import cgi, strtabs, guildenstern/[dispatcher, httpserver]

const port{.intdefine.} = 8080

proc generateHeaders*(headers: HttpHeaders,
                       code: HttpCode = Http200,
                       ver: HttpVersion = HttpVer11
                     ): seq[string] =
  # generate meta line and headers
  # result = $ver & " " & $code & CRLF
  for key, val in headers:
    add(result, key & ": " & val)

proc reply2*(body: string, headers: openArray[tuple[key: string, val: string]]) {.inline, gcsafe, raises: [].} =
  {.cast(raises: []).}:
    let joinedheaders = generateHeaders(headers.newHttpHeaders())
  reply(Http200, unsafeAddr body, joinedheaders)

when isMainModule:
  proc cb() =
    let headers = {"Content-Type": "text/plain"}
    reply2("Hello, World!", headers)
  let server = newHttpServer(cb)
  server.start(port)
  joinThreads(server.thread)
