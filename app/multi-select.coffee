fs    = require "fs"
path  = require "path"
api   = require "../lib/api"

bundle = (p) -> p.replace (new RegExp "^#{process.env.HOME}"), "~"

class FileList
  constructor: ->
    @files = []

  add: (filepath) =>
    filepath = path.resolve __dirname, filepath
    stats = fs.statSync filepath
    return unless stats.isFile()
    unless (@files.some (p) -> p is filepath)
      @files.push filepath

  clear: => @files = []

  remove: (n) =>
    @files.splice n, 1

  get: => @files


module.exports = (Otoshibako) ->
  files = new FileList
  Otoshibako.multiSelect = {
    add: (fp) -> files.add fp
  }

  show = ->
    list.clearItems()
    files.get().forEach (f) -> list.add bundle f
    Otoshibako.screen.render()

  box = Otoshibako.blessed.Box
    top: 1
    bg: "black"

  text = Otoshibako.blessed.Text
    content: "R: Reset, c: Close, u: Upload All, x: Delete from list"
    bg: "cyan"
    top: 0
    left: 1
    right: 1
    height: 1

  list = Otoshibako.blessed.List
    top: 1
    left: 1
    right: 1
    bottom: 2
    bg: "black"
    selectedFg: "lightcyan"
    selectedBg: "lightblack"
    keys: true
    vi:   true

  Otoshibako
    .key list, "S-r", -> files.clear(); show()
    .key list, "c", -> Otoshibako.back()
    .key list, "u", ->
      files.get().forEach (f) ->
        Otoshibako.upload f, Otoshibako.pwd
    .key list, "x", ->
      files.remove list.selected
      show()

  box.append text
  box.append list

  Otoshibako.router.on "multiSelect", ->
    Otoshibako.exchanger.show "multiSelect"
    show()
    list.focus()
    Otoshibako.screen.render()

  Otoshibako.exchanger.add "multiSelect", box
  Otoshibako.screen.append box
