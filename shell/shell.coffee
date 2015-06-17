readline = require "readline"
chalk    = require "chalk"
ls       = require "../lib/ls"
utils    = require "../lib/utils"

rl = readline.createInterface
  input:  process.stdin
  output: process.stdout
  #completer: (line) ->
  #  return [["hoge", "fuga"], line]

decomposer = (line) ->
  ary = []
  index = 0
  f = false
  i = 0
  ary[index] = ""
  while c = line[i++]
    if c is "\""
      f = !f
      continue
    else if !f and c is " "
      index++
      ary[index] = ""
      continue

    ary[index] += c

  return ary



mode = "main" # main, dropbox, filer
dropboxDir = "/"
filerDir = "/"
updatePrompt = () ->
  rl.setPrompt "#{chalk.gray "[ #{chalk.blue dropboxDir} | #{chalk.green filerDir}]"}\n(#{mode})> "

updatePrompt()
rl.prompt()

rl.on "line", (cmd) ->
  args = decomposer cmd
  if mode is "dropbox"
    if args[0] is "cd"
      dropboxDir = args[1]
    else if args[0] is "ls"
      ls "/", true, (err, res) ->
        res.contents.forEach (item) ->
          console.log utils.printFormat process.stdout.columns, chalk.blue(item.path), item.bytes, item.modified

  else if mode is "main"
    if args[0] is "dropbox"
      mode = "dropbox"


  updatePrompt()
  rl.prompt()
