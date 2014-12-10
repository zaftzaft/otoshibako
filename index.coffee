fs   = require "fs"
path = require "path"
auth = require "./lib/auth"
paths = require "./lib/paths"

# Check Dir
base = paths.base
token = paths.token

unless fs.existsSync base
  fs.mkdirSync base
  fs.mkdirSync paths.cache

fs.exists token, (exists) ->
  launcher = -> require "./app/app"

  unless exists
    auth (err, result) ->
      throw err if err
      fs.writeFile token, JSON.stringify(result), ->
        do launcher
  else
    do launcher
