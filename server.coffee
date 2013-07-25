express = require 'express'
handlebars = require 'handlebars'
persistence = new (require './persistence').File './checkins.json'
argv = require('optimist')
    .usage('Checkin\n')
    .demand('p')
    .alias('p', 'port')
    .describe('p', 'Port to serve from.')
    .argv

SERVER_PORT = argv.port

client_data = persistence.load() or {}

app = express()
app.use express.bodyParser()

app.get '/', (req, res) ->
  console.log "someone viewed checkin data from #{req.connection.remoteAddress}"
  template = handlebars.compile '''
    <h1>Checkins</h1>
    <table border="1">
      <tr>
        <td>nickname</td>
        <td>ip</td>
        <td>date</td>
        <td>utc</td>
        <td>minutes since</td>
      </tr>
      {{#reports}}
        <tr>
          <td> {{nickname}} </td>
          <td> {{ip}} </td>
          <td> {{date}} </td>
          <td> {{utc}} </td>
          <td> {{since}} </td>
        </tr>
      {{/reports}}
    </table>
  '''

  reports = []
  for nick, nick_data of client_data
    for ip, date of nick_data
      reports.push
        nickname: nick
        ip: ip
        date: new Date date
        utc: date
        since: (((new Date).getTime() - date) / 1000 / 60).toFixed 2

  res.send template reports: reports

app.post '/api/checkin', (req, res) ->
  remote_ip = req.connection.remoteAddress
  remote_nickname = req.body.nickname

  unless remote_nickname?
    console.warn "WARN: request missing nickname from #{remote_ip}"
    return res.send 400, "missing required form parameter nickname"

  console.log "checkin [#{remote_ip}] (#{remote_nickname})"
  res.send "ok, thanks for checking in!\n\r"

  client_data[remote_nickname] ?= {}
  client_data[remote_nickname][remote_ip] = (new Date).getTime()
  persistence.save client_data

app.get '/api/checkin', (req, res) ->
  res.send 400, """
    <h1>400 Bad Request</h1>
    #{req.url} requires a POST.
  """

app.listen SERVER_PORT, ->
  console.log "server listening on port #{SERVER_PORT}"
console.log "starting server..."
