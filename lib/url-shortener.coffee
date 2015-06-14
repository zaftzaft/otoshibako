request = require "request"

module.exports = (url, callback) ->
  #ux.nu
  request
    url: "http://ux.nu/api/short"
    json: true
    qs: url: url
  , (err, resp, body) ->
    callback null, body.data.url


# Google
#  request.post
#    url: "https://www.googleapis.com/urlshortener/v1/url"
#    json: true
#    body: longUrl: url
#  , (err, resp, body) ->
#    callback null, body.id
