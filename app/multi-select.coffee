fs      = require "fs"
path    = require "path"
async   = require "async"
blessed = require "blessed"
api     = require "../lib/api"

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
      bottom: 2
      bg: "black"
      selectedFg: "lightcyan"
      selectedBg: "lightblack"
      keys: true
      vi:   true

    @status = blessed.Text
      content: ""
      left: 1
      right: 1
      bottom: 1
      bg: "black"

    @box.append @text
    @box.append @list
    @box.append @status

    @list.key "S-r", =>
      @files.clear()
      @screen.render()

    @list.key "c", =>
      @box.hide()
      @hideFn?()
      @screen.render()

    @list.key "u", =>
      tasks = []
      pwd = @screen.query("list").pwd
      i = 0
      @files.get().forEach (f) =>
        tasks.push (cb) =>
          @status.setContent "#{bundle f} -> #{pwd} (#{++i}/#{tasks.length})"
          @screen.render()
          api.filesPut pwd, f, (err, result) ->
            return cb err if err
            cb null

      async.waterfall tasks, (err) =>
        throw err if err
        @status.setContent "Done."
        @files.clear()
        @set()
        @screen.render()



    @list.key "d", =>
      @files.remove @list.selected
      @set()
      #@list.setItems @files.get()
      @screen.render()


    @box.hide()

    @screen.append @box

  show: =>
    @list.clearItems()
    @set()
    @box.show()
    @list.focus()
    @screen.render()

  set: =>
    @files.get().forEach (f) =>
      @list.add bundle f

  add: (fp) =>
    @files.add fp

module.exports = MultiSelect
