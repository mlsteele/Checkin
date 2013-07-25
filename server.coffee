net = require 'net'
fs = require 'fs'
config = require './config'

console.log config

# start checkin server
do ->
  server = net.createServer (socket) ->
    socket_info =
      address: socket.remoteAddress
      port: socket.remotePort

    console.log "client connected"
    console.log socket_info
    socket.on "end", -> console.log "client disconnected"
    socket.on "error", -> console.error "ERROR: client error"

    socket.write "ok, thanks for checking in!\n\r"
    socket.end()

    if config.LOGFILE_ENABLED
      log_entry = "checkin from #{socket_info.address}:#{socket_info.port}\n"
      fs.appendFile config.LOGFILE, log_entry, (err) ->
        if err isnt null
          console.error "ERROR: There was an error writing to the log."
          console.error err

  server.listen config.CHECKIN_PORT, ->
    console.log "checkin server listening."

if config.HTTP_ENABLED
  console.warn "HTTP server not implemented."
