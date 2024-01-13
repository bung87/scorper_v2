import std/[mimetypes, macros]
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

macro acceptMime*( body: untyped): untyped =
  expectKind body,nnkStmtList
  expectKind body[0],nnkCaseStmt
  var matched = genSym(nskvar)
  let ext = body[0][0]
  expectKind ext, nnkIdent
  let extInject = nnkPragmaExpr.newTree(
      ext,
      nnkPragma.newTree(
        ident("inject")
      )
    )
  expectKind body[0][^1],nnkElse
  var stmts = copyNimTree(body)
  var cases = stmts[0][1 .. ^2]
  for n in mitems(cases):
    if n.kind == nnkOfBranch:
      n[^1].add nnkAsgn.newTree(matched, ident("true"))
      n[^1].add nnkBreakStmt.newTree(newEmptyNode())
  var newCases = nnkCaseStmt.newTree(ext)
  for n in cases:
    newCases.add n
  result = nnkStmtList.newTree(
    nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        matched,
        newEmptyNode(),
        ident("false"),
      )
    ),
    nnkForStmt.newTree(
      extInject,
      newCall(bindSym("acceptMimes")),
      newCases
    ),
    nnkIfStmt.newTree(
      nnkElifBranch.newTree(
        nnkPrefix.newTree(
          ident("not"),
          matched
        ),
        body[0][^1][0]
      )
    )
  )