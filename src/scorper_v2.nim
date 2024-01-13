import std/[cgi, strtabs, os, strformat]
import guildenstern/[dispatcher, httpserver]
import urlly
import scorper_v2/posix_send_file

export dispatcher, httpserver

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

proc generateHeaders*(headers: HttpHeaders): seq[string] =
  for key, val in headers:
    add(result, key & ": " & val)

proc reply*(body: string, headers: openArray[tuple[key: string, val: string]]) {.inline, gcsafe, raises: [].} =
  {.cast(raises: []).}:
    let joinedheaders = generateHeaders(headers.newHttpHeaders(titleCase = true))
  reply(Http200, unsafeAddr body, joinedheaders)

proc sendAttachment*(filepath: string, asName: string = "") =
  let filename = if asName.len == 0: filepath.extractFilename else: asName
  let encodedFilename = &"filename*=UTF-8''{encodeUrlComponent(filename)}"
  {.cast(raises: []).}:
    let extroHeaders = newHttpHeaders({
      "Content-Disposition": &"""attachment;filename="{filename}";{encodedFilename}"""
    }, titleCase = true)
    let joinedheaders = generateHeaders(extroHeaders)
  let info = getFileInfo(filepath)
  discard replyStart(Http200, info.size.int, joinedheaders)
  # sendFile(filepath, extroHeaders)
  writeFile(filepath, info.size)
  discard replyFinish()