utils = require "../lib/utils"

module.exports = (Otoshibako) ->
  Otoshibako.byteFormat = utils.byteFormat
  Otoshibako.dateFormat = utils.dateFormat

  Otoshibako.print = (name, bytes, modified) ->
    utils.printFormat Otoshibako.screen.width, name, bytes, modified
