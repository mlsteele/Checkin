os = require 'os'
request = require 'request'
argv = require('optimist')
    .usage('Checkin\n')
    .demand('n').alias('n', 'nickname')
    .describe('n', 'Nickname to checkin as.')
    .demand('h').alias('h', 'hostname')
    .describe('h', 'Server hostname.')
    .demand('p').alias('p', 'port')
    .describe('p', 'Server port.')
    .argv

LOCAL_NICKNAME = argv.nickname
LOCAL_HOSTNAME = os.hostname()
SERVER_HOSTNAME = 'localhost'
SERVER_PORT = argv.port

url = "http://#{SERVER_HOSTNAME}:#{SERVER_PORT}/api/checkin"
request.post url,
  form:
    nickname: LOCAL_NICKNAME
    hostname: LOCAL_HOSTNAME
  (error, response, body) ->
    if error isnt null
      console.error "error checking in with server at #{SERVER_HOSTNAME}:#{SERVER_PORT}"
      console.error error
    else
      console.log "server replied: #{body}"
