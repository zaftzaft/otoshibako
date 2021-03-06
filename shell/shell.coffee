readline = require "readline"
fs       = require "fs"
path     = require "path"
chalk    = require "chalk"
enogu    = require "@zaftzaft/enogu"
utils    = require "../lib/utils"

# Namespace
Shell = {}
Shell.modes = []
Shell.before = null
Shell.current = null
Shell.memory = []
Shell.buffer = []
Shell.pointer = (str) ->
  if str[0] is "@"
    str = Shell.memory[str.slice(1)]
  return str

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

  Shell[name].alias = (alias, cmd) ->
    aliasFn = null

    return unless Shell[name].map.some (obj) ->
      if obj.cmd is cmd
        aliasFn = obj.fn
        return true

    Shell[name].map.push
      cmd: alias
      fn: aliasFn


Shell.mode "global"

Shell.global.cmd "dropbox", (args, cb) ->
  Shell.chmode "dropbox"
  cb null

Shell.global.cmd "filer", (args, cb) ->
  Shell.chmode "filer"
  cb null

Shell.global.cmd "memory", (args, cb) ->
  Shell.more (Shell.memory.map (item, i) -> "[#{i}] #{item}\n"), cb

Shell.global.cmd "buffer", (args, cb) ->
  if /^\d+$/.test args[0]
    unless Shell.buffer[args[0]]
      return cb "Buffer #{args[0]} is not found"
    fs.readFile Shell.buffer[args[0]][1], "utf8", (err, data) ->
      return cb err if err
      console.log data
      cb null
  else
    Shell.more (Shell.buffer.map (item, i) -> "[#{i}] #{item[0]} -> #{item[1]}"), cb

Shell.global.cmd "exit", (args, cb) ->
  Shell.chmode "global"
  cb null

Shell.chmode "global"

Shell.mode "more"

Shell.dropboxDir = "/"
Shell.filerDir = "/"

Shell.rl = rl = readline.createInterface
  input:  process.stdin
  output: process.stdout
  completer: (line) ->
    hits = Shell[Shell.current].map
      .map (m) -> m.cmd
      .filter (c) -> c.indexOf(line) == 0
    return [hits, line]


require("./utils")(Shell)
require("./dropbox")(Shell)
require("./filer")(Shell)


updatePrompt = () ->
  rl.setPrompt "#{chalk.gray "[ #{chalk.blue Shell.dropboxDir} | #{chalk.green Shell.filerDir}]"}
  \n#{enogu.white "(#{Shell.current})>"} \x1b[97m"

updatePrompt()
rl.prompt()

resume = (err) ->
  if err
    console.log enogu.red "" + err
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
    unless cmd.length is 0
      console.log "#{cmd}: command not found"
    resume()
