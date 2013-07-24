net = require "net"

server = net.createServer (socket) ->
  socket_info =
    address: socket.remoteAddress
    port: socket.remotePort

  console.log "client connected"
  console.log socket_info
  socket.on "end", -> console.log "client disconnected"
  socket.on "error", -> console.log "ERROR: client error"

  socket.write "ok, thanks for checking in!\n\r"
  socket.end()

server.listen 8124, ->
  console.log "checkin server listening."
