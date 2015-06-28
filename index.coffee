fs   = require "fs"
path = require "path"
auth = require "./lib/auth"
paths = require "./lib/paths"

# app, shell, cli, debug
mode = "app"

if process.argv[2] is "debug"
  mode = "debug"
  console.log "*** Debug Mode ***"

if process.argv[2] is "cc"
  fs.readdir paths.cache, (err, links) ->
    throw err if err
    links.forEach (name) ->
      fs.unlinkSync path.join(paths.cache, name)
    console.log "Cache files cleared."
  return 0

if process.argv[2] is "shell"
  mode = "shell"



# Check Dir
base = paths.base
token = paths.token

unless fs.existsSync base
  fs.mkdirSync base
  fs.mkdirSync paths.cache

fs.exists token, (exists) ->
  launcher = ->
    if mode is "shell"
      require "./shell/shell"
    else
      require "./app/app"

  unless exists
    auth (err, result) ->
      throw err if err
      fs.writeFile token, JSON.stringify(result), ->
        do launcher
  else
    do launcher
