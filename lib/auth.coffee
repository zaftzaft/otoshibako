readline     = require "readline"
qs           = require "querystring"
request      = require "request"
Dropbox      = require "./consumer"
urlShortener = require "./url-shortener"

getAccessToken = (oauth, callback) ->
  request.post
    url: "https://api.dropbox.com/1/oauth/access_token"
    oauth:
      consumer_key:    Dropbox.appKey,
      consumer_secret: Dropbox.appSecret,
      token:           oauth.oauth_token,
      token_secret:    oauth.oauth_token_secret
  , (err, resp, body) ->
    unless resp.statusCode is 200
      body = JSON.parse body
      return callback new Error body.error

    return callback err if err
    callback null, qs.parse body

module.exports = (callback) ->
  request.post
    url: "https://api.dropbox.com/1/oauth/request_token"
    oauth:
      consumer_key:    Dropbox.appKey
      consumer_secret: Dropbox.appSecret
  , (err, resp, body) ->
    return callback err if err
    o = qs.parse body

    authUrl =  "https://www.dropbox.com/1/oauth/authorize?#{
      qs.stringify oauth_token: o.oauth_token
    }"
    console.log authUrl

    rl = readline.createInterface
      input:  process.stdin
      output: process.stdout
    rl.setPrompt "> "

    console.log "And press enter After authentication"
    console.log "s : ux.nu URL Shortener"

    rl.on "line", (cmd) ->
      if cmd is ""
        getAccessToken o, callback
        rl.close()
        return
      else if cmd is "s"
        urlShortener authUrl, (err, sUrl) ->
          return callback err if err
          console.log sUrl
          rl.prompt()
      else
        rl.prompt()
