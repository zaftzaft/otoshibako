fs       = require "fs"
path     = require "path"
temp     = require "temp"
enogu    = require "@zaftzaft/enogu"
paths    = require "../lib/paths"
api      = require "../lib/api"
ls       = require "../lib/ls"
utils    = require "../lib/utils"

module.exports = (Shell) ->
  temp.track()

  Shell.mode "dropbox"

  Shell.dropbox.resolve = (str) ->
    if str[0] is "@"
      Shell.pointer str
    else
      path.posix.join Shell.dropboxDir, str

  list = (useCache, cb) ->
    Shell.memory = []
    ls "#{Shell.dropboxDir}", useCache, (err, res) ->
      Shell.more (utils.sort(res.contents).map (item, i, ary) ->
        Shell.memory.push item.path
        name = item.path.split("/").pop()
        if item.is_dir
          name += "/"

        margin = new Array(
          ("" + ary.length).length - ("" + i).length + 1
        ).join " "

        utils.printFormat(
          process.stdout.columns,
          "#{enogu.cyan "[#{i}]"}#{margin} #{enogu.blue name}",
          item.bytes,
          item.modified
        )
      ), cb


  Shell.dropbox.cmd "ls", (args, cb) -> list true, cb
  Shell.dropbox.cmd "fetch", (args, cb) -> list false, cb

  Shell.dropbox.alias "ll", "ls"


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
    to = path.posix.join Shell.dropboxDir, Shell.dropbox.resolve args[1]
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


  Shell.dropbox.cmd "cat", (args, cb) ->
    fp = Shell.dropbox.resolve args[0]
    temp.open "otoshibako", (err, info) ->
      return cb err if err
      api.files fp, info.path, (->), (err, file) ->
        return cb err if err
        console.log file
        fs.readFile info.path, "utf8", (err, data) ->
          Shell.buffer.push [fp, info.path]
          console.log data
          cb null


  download = (remote, local, cb) ->
    Shell.confirm "Download #{remote} to #{local}", ->
      api.files remote, local, (->), (err, file) ->
        return cb err if err
        console.log "Downloaded #{file}"
        cb null
    , cb

  Shell.dropbox.cmd "download", (args, cb) ->
    download Shell.dropbox.resolve(args[0]), paths.expand("~/Desktop"), cb
  Shell.dropbox.cmd "get", (args, cb) ->
    download Shell.dropbox.resolve(args[0]), Shell.filerDir, cb


  Shell.dropbox.cmd "rm", (args, cb) ->
    fp = Shell.dropbox.resolve args[0]
    Shell.confirm "Delete #{fp}", ->
      api.delete fp, (err, result) ->
        return cb err if err
        console.log result
        cb null
    , cb

