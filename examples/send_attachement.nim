import scorper_v2

const port{.intdefine.} = 8080

when isMainModule:
  proc cb()  =
    {.cast(raises: []).}:
      sendAttachment(currentSourcePath)

  let server = newHttpServer(cb)
  server.start(port)
  joinThreads(server.thread)
