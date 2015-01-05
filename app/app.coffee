path = require "path"
blessed = require "blessed"

blessed.Node::query = (id) ->
  el = null
  @children.some (a, i) ->
    if a.id is id
      el = a
      true
    else
      false
  return el

blessed.FileManager::getFocusedItem = ->
  item = @getItem(@selected)
  value = item.content
    .replace /\{[^{}]+\}/g, ""
    .replace /@$/, ""
  file = path.resolve @cwd, value
  return file


screen = blessed.Screen()
screen.key ["q", "C-c"], -> process.exit 0

status = blessed.Element {
  bg: "blue"
  top: 0
  width: "100%"
  height: 1
  content: ""
}
status.id = "status"

help = blessed.Box
  width: "70%"
  height: "70%"
  left: "center"
  top: "center"
  bg: "black"
  border:
    type: "line"
    fg: "red"
    bg: "black"
help.id = "hide"
help.hide()

help.key ["c", "escape"], ->
  help.hide()
  screen.render()

screen.key "h", ->
  [
    " f: Dropbox <-> Filer"
    " ~: Jump to home dir (filer)"
    " D: Jump to Desktop dir (filer)"
    " Space: File select (filer)"
    " s: Show selected files (filer)"
    " m: Make Dir (dropbox)"
    " C-e: Escape non ascii (dropbox)"
    " q: Quit"
  ].forEach (s, i) -> help.setLine i, s
  help.show()
  help.focus()
  screen.render()

screen.append status

require("./dropbox")(blessed, screen)
require("./filer")(blessed, screen)

screen.append help

list = screen.query "list"
filemanager = screen.query "filemanager"
flg = true
screen.key "f", ->
  if flg = !flg
    filemanager.hide()
    list.show()
    list.focus()
  else
    list.hide()
    filemanager.show()
    filemanager.focus()

  screen.render()


screen.render()
