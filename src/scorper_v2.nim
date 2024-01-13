import std/[cgi, strtabs, os, strformat, paths, mimetypes]
import guildenstern/[dispatcher, httpserver]
import urlly
import scorper_v2/[posix_send_file, accept_parser, accept_mime, router]

export accept_parser, accept_mime, router
export dispatcher, httpserver

const mimeDb = newMimetypes()

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

proc hasSuffix(s: string): bool =
  let sLen = s.len - 1
  var i = sLen
  while i != 0:
    if s[i] == '.':
      return true
    dec i

proc serveStatic*(prefix: string) {.gcsafe, nimcall, raises: [].} =
  ## Relys on `StaticDir` environment variable
  let meth = getMethod()
  if meth != $HttpGet and meth != $HttpHead:
    reply(Http405)
    return
  var relPath: string
  let uri = getUri()
  {.cast(raises: []).}:
    let url = parseUrl(uri)
  # var prefix: string
  try:
    relPath = decodeUrlComponent(Path(url.path).relativePath(Path(prefix)).string)
  except Exception:
    discard
  if not hasSuffix(relPath):
    relPath = relPath / "index.html"
  {.cast(raises: []).}:
    let absPath = absolutePath(os.getEnv("StaticDir") / relPath)
  echo absPath
  if not absPath.fileExists:
    reply(Http404)
    return
  if meth == $HttpHead:
    var (_, _, ext) = splitFile(absPath)
    let mime = mimeDb.getMimetype(ext)
    # meta.unsafeGet.headers.ContentType mime
    # meta.unsafeGet.headers.AcceptRanges "bytes"
    # var joinedheaders = generateHeaders(meta.unsafeGet.headers, Http200)
    # reply(Http200, joinedheaders)
    return
  {.cast(raises: []).}:
    let info = getFileInfo(absPath)
  discard replyStart(Http200, info.size.int, [""])
  # sendFile(filepath, extroHeaders)
  writeFile(absPath, info.size)
  discard replyFinish()