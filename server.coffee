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
    <style type="text/css">
      body {
        font-family: Helvetica;
      }

      tr.header {
        background-color: #FFF3BD;
      }

      td {
        padding: 0.5em;
	border: 1px solid #ddd;
      }

      .mono {
        font-family: "Courier New", monospace;
      }
    </style>
    <h1>Checkins</h1>
    <table border="0">
      <tr class="header">
        <td>nickname</td>
        <td>IP</td>
        <td>Minutes Since</td>
        <td>Date</td>
        <td>Utc</td>
      </tr>
      {{#reports}}
        <tr>
          <td> {{nickname}} </td>
          <td class="mono"> {{ip}} </td>
          <td class="mono"> {{since}} </td>
          <td> {{date}} </td>
          <td class="mono"> {{utc}} </td>
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

  reports.sort (a, b) ->
    return b.date - a.date

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

app.post '/api/query', (req, res) ->
  query_nickname = req.body.nickname

  nick_data = client_data[query_nickname]
  if nick_data?
    records = ({ip: ip, date: date} for ip, date of nick_data)
    records.sort (a, b) -> b.date - a.date
    res.send 200, records[0].ip
  else
    res.send 404, "unknown.ip"

app.listen SERVER_PORT, ->
  console.log "server listening on port #{SERVER_PORT}"
console.log "starting server..."
