os = require 'os'
request = require 'request'
argv = require('optimist')
    .usage('Checkin\n')
    .demand('n')
    .alias('n', 'nickname')
    .describe('n', 'Nickname to checkin as.')
    .argv

LOCAL_NICKNAME = argv.n
LOCAL_HOSTNAME = os.hostname()
SERVER_HOSTNAME = 'localhost'
SERVER_PORT = 8127

url = "http://#{SERVER_HOSTNAME}:#{SERVER_PORT}/api/checkin"
request.post url,
  form:
    nickname: LOCAL_NICKNAME
    hostname: LOCAL_HOSTNAME
  (error, response, body) ->
    if error isnt null
      logger.error "http problem publishing node"
      logger.error error
    else
      console.log "server replied: #{body}"
