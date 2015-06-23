chalk    = require "chalk"
enogu    = require "@zaftzaft/enogu"
ls       = require "../lib/ls"
utils    = require "../lib/utils"
module.exports = (Shell) ->
  Shell.mode "dropbox"

  list = (useCache, cb) ->
    Shell.memory = []
    ls "#{Shell.dropboxDir}", useCache, (err, res) ->
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


  Shell.dropbox.cmd "ls", (args, cb) -> list true, cb
  Shell.dropbox.cmd "fetch", (args, cb) -> list false, cb


  Shell.dropbox.cmd "cd", (args, cb) ->
    dir = Shell.pointer args[0]

    unless dir
      return cb "dir not found"

    Shell.dropboxDir = dir
    cb null


  Shell.global.cmd "exit", (args, cb) ->
    Shell.chmode "global"
    cb null
