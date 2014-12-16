fs = require "fs"
path     = require "path"
blessed = require "blessed"

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

class MultiSelect
  constructor: (@screen) ->
    @files = new FileList

    @box = blessed.Box
      width:  "80%"
      height: "80%"
      left:   "center"
      top:    "center"
      bg:     "black"
      border:
        type: "line"
        fg:   "cyan"
        bg:   "black"

    @text = blessed.Text
      content: "R: Reset, c: Close, u: Upload All, d: Delete from list"
      bg: "cyan"
      top: 1
      left: 1
      right: 1
      height: 1

    @list = blessed.List
      top: 2
      left: 1
      right: 1
      bottom: 1
      bg: "black"
      selectedFg: "lightcyan"
      selectedBg: "lightblack"
      keys: true
      vi:   true

    @box.append @text
    @box.append @list

    @list.key "S-r", =>
      @files.clear()
      @screen.render()

    @list.key "c", =>
      @box.hide()
      @hideFn?()
      @screen.render()

    @list.key "u", =>

    @list.key "d", =>
      @files.remove @list.selected
      @screen.render()


    @box.hide()

    @screen.append @box

  show: =>
    @list.clearItems()
    @files.get().forEach (f) =>
      @list.add f
    @box.show()
    @list.focus()
    @screen.render()

  add: (fp) =>
    @files.add fp

module.exports = MultiSelect
