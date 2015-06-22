readline = require "readline"
chalk    = require "chalk"
enogu    = require "@zaftzaft/enogu"
ls       = require "../lib/ls"
utils    = require "../lib/utils"

# Namespace
Shell = {}
Shell.modes = []
Shell.before = null
Shell.current = null
Shell.chmode = (name) ->
  if ~Shell.modes.indexOf name
    Shell.before = Shell.current
    Shell.current = name
Shell.mode = (name) ->
  Shell.modes.push name
  Shell[name] = {}
  Shell[name].map = []
  Shell[name].cmd = (cmd, fn) ->
    Shell[name].map.push
      cmd: cmd
      fn: fn

Shell.mode "global"
Shell.global.cmd "dropbox", (cb) ->
  Shell.chmode "dropbox"
  cb null
Shell.chmode "global"

Shell.mode "more"

Shell.mode "dropbox"
Shell.dropbox.cmd "ls", (cb) ->
  ls "/", true, (err, res) ->
    Shell.more (utils.sort(res.contents).map (item) ->
      utils.printFormat(
        process.stdout.columns,
        chalk.blue(item.path.split("/").pop()),
        item.bytes,
        item.modified
      )
    ), cb


rl = readline.createInterface
  input:  process.stdin
  output: process.stdout
  completer: (line) ->
    hits = Shell[Shell.current].map
      .map (m) -> m.cmd
      .filter (c) -> c.indexOf(line) == 0
    return [hits, line]

require("./utils")(Shell)



mode = "main" # main, dropbox, filer
dropboxDir = "/"
filerDir = "/"
updatePrompt = () ->
  rl.setPrompt "#{chalk.gray "[ #{chalk.blue dropboxDir} | #{chalk.green filerDir}]"}
  \n#{enogu.white "(#{Shell.current})>"} \x1b[97m"

updatePrompt()
rl.prompt()

resume = ->
  updatePrompt()
  rl.prompt()

rl.on "line", (cmd) ->
  if Shell.current is "more"
    Shell.more.fn()
    return

  #args = Shell.decomposer cmd

  flg = Shell[Shell.current].map.some (obj) ->
    if obj.cmd is cmd
      obj.fn resume
      return true
  unless flg
    console.log "#{cmd}: command not found"
    resume()
