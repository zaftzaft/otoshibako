readline = require "readline"
path     = require "path"
chalk    = require "chalk"
enogu    = require "@zaftzaft/enogu"
ls       = require "../lib/ls"
utils    = require "../lib/utils"

# Namespace
Shell = {}
Shell.modes = []
Shell.before = null
Shell.current = null
Shell.memory = []
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
Shell.global.cmd "dropbox", (args, cb) ->
  Shell.chmode "dropbox"
  cb null
Shell.global.cmd "memory", (args, cb) ->
  Shell.more (Shell.memory.map (item, i) -> "[#{i}] #{item}\n"), cb

Shell.chmode "global"

Shell.mode "more"

Shell.mode "dropbox"
Shell.dropbox.cmd "ls", (args, cb) ->
  Shell.memory = []
  ls "#{Shell.dropboxDir}", true, (err, res) ->
    Shell.more (utils.sort(res.contents).map (item, i) ->
      name = item.path.split("/").pop()
      if item.is_dir
        name += "/"
      Shell.memory.push item.path
      utils.printFormat(
        process.stdout.columns,
        "#{enogu.cyan "[#{i}]"}#{chalk.blue(name)}",
        item.bytes,
        item.modified
      )
    ), cb

Shell.dropbox.cmd "cd", (args, cb) ->
  dir = args[0]
  if dir[0] is "@"
    dir = Shell.memory[dir.slice(1)]

  unless dir
    return cb "dir not found"

  Shell.dropboxDir = dir
  cb null

Shell.global.cmd "exit", (args, cb) ->
  Shell.chmode "global"
  cb null

Shell.dropboxDir = "/"
Shell.filerDir = "/"

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
updatePrompt = () ->
  rl.setPrompt "#{chalk.gray "[ #{chalk.blue Shell.dropboxDir} | #{chalk.green Shell.filerDir}]"}
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

  args = Shell.decomposer cmd
  cmd = args.splice(0, 1)[0]

  flg = Shell[Shell.current].map.some (obj) ->
    if obj.cmd is cmd
      obj.fn args, resume
      return true

  unless flg
    flg = Shell["global"].map.some (obj) ->
      if obj.cmd is cmd
        obj.fn args, resume
        return true

  unless flg
    console.log "#{cmd}: command not found"
    resume()
