path     = require "path"
chalk    = require "chalk"
enogu    = require "@zaftzaft/enogu"
api      = require "../lib/api"
ls       = require "../lib/ls"
utils    = require "../lib/utils"

module.exports = (Shell) ->
  Shell.mode "dropbox"

  Shell.dropbox.resolve = (str) ->
    if str[0] is "@"
      Shell.pointer str
    else
      path.posix.join Shell.dropboxDir, str

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


  Shell.dropbox.cmd "mkdir", (args, cb) ->
    fp = path.posix.join Shell.dropboxDir, args[0]
    Shell.confirm "create #{fp} dir", ->
      api.createFolder fp, (err, res) ->
        return cb err if err
        console.log res
        cb null
    , cb


  Shell.dropbox.cmd "mv", (args, cb) ->
    from = Shell.dropbox.resolve args[0]
    to = path.posix.join Shell.dropboxDir, args[1]
    Shell.confirm "#{from} -> #{to}", ->
      api.move from, to, (err, res) ->
        return cb err if err
        console.log res
        cb null
    , cb


  Shell.dropbox.cmd "cd", (args, cb) ->
    dir = Shell.dropbox.resolve args[0]

    unless dir
      return cb "dir not found"

    Shell.dropboxDir = dir
    cb null


