import cgi, strtabs, guildenstern/[dispatcher, httpserver]
     
proc handleGet() =
  let html = """
    <!doctype html><title>GuildenStern Example</title><body>
    <form action="http://localhost:5051" method="post" accept-charset="utf-8">
    <input name="say" id="say" value="Hi"><button>Send"""
  reply(html)

let getserver = newHttpServer(handleGet)
getserver.start(8080)
joinThreads(getserver.thread)
