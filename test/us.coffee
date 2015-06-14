urlShortener = require "../lib/url-shortener"

urlShortener "http://www.google.com", (err, sUrl) ->
  console.log sUrl
