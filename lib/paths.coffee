path = require "path"

expand = (p) -> p.replace /^~/, process.env.HOME

base = expand "~/.otoshibako"
token = path.join base, "token"
cache = path.join base, "cache"
index = path.join cache, "index"


module.exports =
  base: base
  token: token
  cache: cache
  index: index
  expand: expand
