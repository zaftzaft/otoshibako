readline = require "readline"
qs       = require "querystring"
request  = require "request"
Dropbox  = require "./consumer"

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
    console.log "https://www.dropbox.com/1/oauth/authorize?#{
      qs.stringify oauth_token: o.oauth_token
    }"
    rl = readline.createInterface
      input:  process.stdin
      output: process.stdout
    rl.question "And press enter After authentication", ->
      getAccessToken o, callback
      rl.close()
