path = require "path"
os   = require "os"

expand = (p) ->
  if ~os.platform().indexOf "win"
    home = path.join process.env.HOMEDRIVE, process.env.HOMEPATH
  else
    home = process.env.HOME

  return path.join p.replace(/^~/, home)


if ~os.platform().indexOf "win"
  base = path.join process.env.LOCALAPPDATA, "otoshibako"
else
  base = expand "~/.otoshibako"

token = path.join base, "token"
cache = path.join base, "cache"
index = path.join cache, "index"


module.exports =
  base:   base
  token:  token
  cache:  cache
  index:  index
  expand: expand
