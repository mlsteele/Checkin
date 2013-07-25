fs = require 'fs'

class File
  constructor: (@file_path) ->

  load: ->
    if fs.existsSync @file_path
      return JSON.parse fs.readFileSync @file_path
    else
      null

  save: (data) ->
    fs.writeFileSync @file_path, JSON.stringify data

module.exports =
  File: File
