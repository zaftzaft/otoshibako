fs    = require "fs"
path  = require "path"
async = require "async"
paths = require "../lib/paths"
utils = require "../lib/utils"

module.exports = (Shell) ->
  Shell.mode "filer"
  Shell.filerDir = paths.expand "~"

  Shell.filer.cmd "ls", (args, cb) ->
    Shell.memory = []
    fs.readdir Shell.filerDir, (err, links) ->
      async.map links, (item, callback) ->
        fs.lstat path.join(Shell.filerDir, item), callback
      , (err, results) ->
        return cb err if err

        data = results.reduce (o, st, i) ->
          if st.isDirectory()
            o.dir.push [links[i], st]
          else
            o.file.push [links[i], st]
          return o
        , {dir: [], file: []}

        compare = (a, b) -> if a[0] > b[0] then 1 else -1
        data.dir = data.dir.sort compare
        data.file = data.file.sort compare

        formatted = []
          .concat data.dir, data.file
          .map (item, i) ->
            Shell.memory.push path.join(Shell.filerDir, item[0])
            name = item[0]
            if item[1].isDirectory()
              name += "/"

            name = name
              .replace "{", "{$"
              .replace "}", "$}"

            utils.printFormat(
              process.stdout.columns,
              "[#{i}] #{name}",
              item[1].size,
              item[1].mtime
            )
        Shell.more formatted, cb



  Shell.filer.cmd "cat", (args, cb) ->
    fp = Shell.pointer args[0]
    fs.readFile fp, "utf8", (err, data) ->
      return cb err if err
      console.log data
      cb null

  Shell.filer.cmd "cd", (args, cb) ->
    dir = Shell.pointer args[0]
    Shell.filerDir = dir
    cb null
