path = require "path"
blessed = require "blessed"
director = require "director"
Exchanger = require "./exchanger"

blessed.FileManager::getFocusedItem = ->
  item = @getItem(@selected)
  value = item.content
    .replace /\{[^{}]+\}/g, ""
    .replace /@$/, ""
  file = path.resolve @cwd, value
  return file

Otoshibako = {}
Otoshibako.$ = {}
Otoshibako.router = new director.cli.Router()
Otoshibako.location = null
Otoshibako.pwd = null # Dropbox Current Dir
Otoshibako.goto = (param) ->
  Otoshibako.location = param
  Otoshibako.router.dispatch "on", param
Otoshibako.back = -> Otoshibako.goto Otoshibako.exchanger.previous
Otoshibako.exchanger = new Exchanger()
Otoshibako.blessed = blessed
Otoshibako.key = (el, type, handle) ->
  el.key type, -> handle() if el.focused
  return Otoshibako

screen = blessed.screen
  fullUnicode: true
screen.key ["q", "C-c"], -> process.exit 0

Otoshibako.screen = screen

Otoshibako.$.status = blessed.Box
  bg: "blue"
  top: 0
  width: "100%"
  height: 1
screen.append Otoshibako.$.status

require("./print")(Otoshibako)
require("./stream")(Otoshibako)
require("./dropbox")(Otoshibako)
require("./filer")(Otoshibako)
require("./multi-select")(Otoshibako)

# Overlay
require("./help")(Otoshibako)

flg = true
screen.key "f", ->
  unless Otoshibako.$.dropbox.focused or Otoshibako.$.filer.focused
    return null

  if flg = !flg
    Otoshibako.goto "dropbox"
  else
    Otoshibako.goto "filer"

screen.key "s", ->
  unless Otoshibako.$.dropbox.focused or Otoshibako.$.filer.focused
    return null
  Otoshibako.goto "stream"

screen.render()
