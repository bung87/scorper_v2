import mimetypes
import guildenstern/[httpserver]
import scorper_v2/[accept_parser]

const mimeDb = newMimetypes()

func getExt*(mime: string): string {.inline.} =
  result = mimeDb.getExt(mime, default = "")

iterator acceptMimes*(): string =
  let parser = accpetParser()
  var mimes = newSeq[tuple[mime: string, q: float, extro: int, typScore: int]]()
  var header: array[1, string]
  parseHeaders(["accept"], header)
  {.cast(raises: []), gcsafe.}:
    let matched = parser.match(header[0], mimes)
  if matched.ok:
    for item in mimes:
      {.cast(raises: []).}:
        let ext = getExt(item.mime)
        if ext.len > 0:
          yield ext