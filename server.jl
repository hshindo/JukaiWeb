using HttpServer
using WebSockets
using JSON
using JLD
using Jukai
using Jukai.Tokenization
using Jukai.POSTagging
using Merlin

include("conf.jl")

const clients = Dict()
const tokenizer = load("data/tokenizer_50.jld", "tokenizer")
const conf = begin
  e = readconf(joinpath(dirname(@__FILE__),"conf/visual.conf"))
  d = Dict("entity_types" => e)
  JSON.json(d)
end

const postagger = begin
  println("training postagger...")
  p = POSTagger()
  POSTagging.train(p, "data/wsj_00-18.conll", "data/wsj_22-24.conll")
  println("finish.")
  p
end

wsh = WebSocketHandler() do req, client
  println("Client: $(client.id) is connected.")
  write(client, conf)
  while true
    #println("Request from $(client.id) recieved.")
    msg = bytestring(read(client))
    length(msg) > 1000 && continue
    chars = convert(Vector{Char}, msg)
    doc = Tokenization.decode(tokenizer, chars)
    POSTagging.decode!(postagger, doc)
    doc = map(x -> map(to_dict, x), doc)
    res = JSON.json(doc)
    #println(res)
    write(client, res)
  end
end

onepage = readall(joinpath(dirname(@__FILE__), "index.html"))
httph = HttpHandler() do req::Request, res::Response
  Response(onepage)
end
server = Server(httph, wsh)
run(server, 3000)

#=
const sample_tokens = [
  Token(1, 6, 1, "Pierre", 1, "NNP", -2, 2),
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
  Token(14, ".", 13, ".", -1, 8)]
=#
