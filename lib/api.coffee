fs      = require "fs"
path    = require "path"
pjoin   = path.join
request = require "request"
Dropbox = require "./consumer"
paths   = require "./paths"

fixDir = (cp) ->
  cp
    .split "/"
    .map (a) -> encodeURIComponent a
    .join "/"

genOAuth = do ->
  p = paths.token
  token = fs.readFileSync p, "utf8"
  token = JSON.parse token
  return ->
    {
      consumer_key:    Dropbox.appKey
      consumer_secret: Dropbox.appSecret
      token:           token.oauth_token
      token_secret:    token.oauth_token_secret
    }


API = {}

API.metadata = (path, callback) ->
  path = path.slice 1 if path[0] is "/"
  path = fixDir path
  request
    url: "https://api.dropbox.com/1/metadata/auto/#{path}"
    oauth: genOAuth()
  , (err, resp, body) ->
    return callback err if err
    if resp.statusCode is 401
      return callback new Error body
    callback null, JSON.parse body


API.delta = (options = {}, callback) ->
  request.post
    url: "https://api.dropbox.com/1/delta"
    oauth: genOAuth()
  , (err, resp, body) ->
    return callback err if err
    if resp.statusCode is 401
      return callback new Error body
    callback null, JSON.parse body


API.files = (remote, local, progressCallback, callback) ->
  remote = remote.slice 1 if remote[0] is "/"
  progress = -> progressCallback ws.bytesWritten, clen
  clen = 1
  filename = remote.split("/").pop()

  ws = fs.createWriteStream path.join(local, filename)
  ws.on "finish", ->
    do progress
    callback null, path.join(local, filename)

  request {
    url: "https://api-content.dropbox.com/1/files/auto/#{fixDir remote}"
    oauth: genOAuth()
  }
    .on "response", (resp) ->
      if resp.statusCode is 401
        return callback new Error remote
      clen = +resp.headers["content-length"]
    .on "data", progress
    .pipe ws


API.filesPut = (to, from, callback) ->
  to = to.slice 1 if to[0] is "/"
  to = path.posix.join to, path.basename(from)
  to = fixDir to
  fs.exists from, (exists) ->
    return callback "File not found" unless exists
    fs
      .createReadStream from
      .pipe request.put
        url: "https://api-content.dropbox.com/1/files_put/auto/#{to}"
        oauth: genOAuth()
      , (err, resp, body) ->
        return callback err if err
        if resp.statusCode isnt 200
          return callback new Error body
        callback null, JSON.parse body


API.move = (from, to, callback) ->
  request.post
    url: "https://api.dropbox.com/1/fileops/move"
    form:
      root: "dropbox"
      from_path: from
      to_path: to
    oauth: genOAuth()
  , (err, resp, body) ->
    return callback err if err
    if resp.statusCode isnt 200
      return callback new Error body
    callback null, JSON.parse body


API.createFolder = (name, callback) ->
  name = fixDir name
  request.post
    url: "https://api.dropbox.com/1/fileops/create_folder"
    form:
      root: "dropbox"
      path: name
    oauth: genOAuth()
  , (err, resp, body) ->
    return callback err if err
    if resp.statusCode isnt 200
      return callback new Error body
    callback null, JSON.parse body


API.delete = (name, callback) ->
  request.post
    url: "https://api.dropbox.com/1/fileops/delete"
    form:
      root: "dropbox"
      path: fixDir name
    oauth: genOAuth()
  , (err, resp, body) ->
    return callback err if err
    if resp.statusCode isnt 200
      return callback new Error body
    callback null, JSON.parse body


module.exports = API
