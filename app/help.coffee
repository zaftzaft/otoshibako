module.exports = (Otoshibako) ->
  help = Otoshibako.blessed.Box
    width: "70%"
    height: "70%"
    left: "center"
    top: "center"
    bg: "black"
    label: "Help"
    border:
      type: "line"
      fg: "red"
      bg: "black"

  Otoshibako.key help, ["c", "escape"],  ->
    help.hide()
    Otoshibako.screen.render()

  help.hide()
  Otoshibako.screen.append help
  Otoshibako.screen.key "h", ->
    unless Otoshibako.$.dropbox.focused or Otoshibako.$.filer.focused
      return null

    [
      " f: Dropbox <-> Filer"
      " s: Show Stream"
      " ~: Jump to home dir (filer)"
      " D: Jump to Desktop dir (filer)"
      " Space: File select (filer)"
      " m: Show selected files (filer)"
      " m: Make Dir (dropbox)"
      " q: Quit"
    ].forEach (s, i) -> help.setLine i, s
    help.show()
    help.focus()
    Otoshibako.screen.render()
