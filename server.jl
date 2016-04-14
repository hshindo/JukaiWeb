using HttpServer
using WebSockets
using JSON
using Jukai
using Jukai.Tokenization

wsh = WebSocketHandler() do req, client
  println("Client id: $(client.id) is connected.")
  while true
    msg = bytestring(read(client))
    #doc = tokenize(msg)
    #out = map(s -> join(s, " "), doc)
    tokens = [
      Token(1, "Pierre", 1, "NNP", -2, 2),
      Token(2, "Vinken", 2, "NNP", -1, 8),
      Token(3, ",", 3, ",", -2, 2),
      Token(4, "61", 4, "CD", -4, 5),
      Token(5, "years", 5, "NNS", -3, 6),
      Token(6, "old", 6, "JJ", -2, 2),
      Token(7, ",", 7, ",", -2, 2),
      Token(8, "will", 8, "MD", 0, 0),
      Token(9, "join", 9, "VB", -1, 8),
      Token(10, "the", 10, "DT", -3, 11),
      Token(11, "board", 11, "NN", -2, 9),
      Token(12, "Nov.", 12, "NNP", -2, 9),
      Token(13, "29", 13, "CD", -3, 12),
      Token(14, ".", 13, ".", -1, 8)
    ]
    tokens = map(to_dict, tokens)
    doc = []
    push!(doc, tokens)
    res = JSON.json(doc)
    println(res)
    write(client, res)
    #for s in doc
    #  write(client, join(s, " "))
    #end
  end
end

onepage = readall(joinpath(dirname(@__FILE__), "index.html"))
httph = HttpHandler() do req::Request, res::Response
  Response(onepage)
end
server = Server(httph, wsh)
#run(server, ip"163.221.116.33", 5000) # chasen.naist.jp
run(server, 3000) # localhost
