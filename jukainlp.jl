using HttpServer
using WebSockets
using JSON
using Jukai
using Jukai.Tokenization

wsh = WebSocketHandler() do req, client
  println("Client id: $(client.id) is connected.")
  while true
    msg = bytestring(read(client))
    doc = tokenize(msg)
    out = map(s -> join(s, " "), doc)
    write(client, JSON.json(out))
    #for s in doc
    #  write(client, join(s, " "))
    #end
  end
end

onepage = readall(joinpath(dirname(@__FILE__), "jukainlp.html"))
httph = HttpHandler() do req::Request, res::Response
  Response(onepage)
end
server = Server(httph, wsh)
#run(server, ip"163.221.116.33", 5000) # chasen.naist.jp
run(server, 5001) # localhost
