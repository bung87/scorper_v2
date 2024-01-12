import scorper_v2
import cgi, os, strformat, strtabs, guildenstern/[dispatcher, httpserver]
import urlly
import send_file
const port{.intdefine.} = 8091

proc writeFile(fname: string, size: int) =
  var handle = 0
  var file: File
  try:
    file = open(fname)
  except CatchableError as e:
    # try:
    #   req.server.logSub.next(e.msg)
    # except CatchableError:
    #   discard
    return
  when defined(windows):
    handle = int(getOsFileHandle(file))
  else:
    handle = int(getFileHandle(file))

  var s = size
  discard sendfile(http.socketdata.socket.int, handle, 0, s)
  close(file)

proc reply*(body: string, headers: openArray[tuple[key: string, val: string]]) {.inline, gcsafe, raises: [].} =
  {.cast(raises: []).}:
    let joinedheaders = $headers.newHttpHeaders()
  reply(Http200, unsafeAddr body, unsafeAddr joinedheaders)

proc sendAttachment*(filepath: string, asName: string = "") =
  let filename = if asName.len == 0: filepath.extractFilename else: asName
  let encodedFilename = &"filename*=UTF-8''{encodeUrlComponent(filename)}"
  {.cast(raises: []).}:
    let extroHeaders = newHttpHeaders({
      "Content-Disposition": &"""attachment;filename="{filename}";{encodedFilename}"""
    })
    let joinedheaders = $extroHeaders
  let info = getFileInfo(filepath)
  echo replyStart(Http200, info.size, unsafeAddr joinedheaders)
  # sendFile(filepath, extroHeaders)
  writeFile(filepath, info.size)
  echo replyFinish()

when isMainModule:
  proc cb()  =
    {.cast(raises: []).}:
      sendAttachment(currentSourcePath)

  let server = newHttpServer(cb)
  server.start(port)
  joinThreads(server.thread)
