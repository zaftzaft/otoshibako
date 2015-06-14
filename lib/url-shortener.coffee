request = require "request"

module.exports = (url, callback) ->
  request.post
    url: "https://www.googleapis.com/urlshortener/v1/url"
    json: true
    body: longUrl: url
  , (err, resp, body) ->
    callback null, body.id
