fs       = require "fs"
{expand} = require "../lib/paths"

module.exports = (Otoshibako) ->
  menu = (parent, data) ->
    parent = Otoshibako.screen
    el = Otoshibako.blessed.Box
      width: "80%"
      height: "80%"
      left: "center"
      top: "center"
      border:
        type: "line"
        fg: "blue"
        bg: "black"

    parent.append el

    fs.lstat data, (err, st) ->
      #el.file = file
      el.setLine 0, "P: #{data}"
      el.setLine 1, "CT: #{Otoshibako.dateFormat st.ctime}"
      el.setLine 2, "MT: #{Otoshibako.dateFormat st.mtime}"
      el.setLine 3, "S: #{st.size} (#{Otoshibako.byteFormat st.size})"
      el.setLine 4, "c: Close, u: Upload"
      Otoshibako.screen.render()

    el.focus()
    el.key "c", -> el.detach(); Otoshibako.screen.render()
    el.key "u", ->
      Otoshibako.upload data, Otoshibako.pwd
      Otoshibako.goto "stream"
    return el

  filemanager = Otoshibako.blessed.FileManager
    cwd: "."
    bg: "black"
    top: 1
    selectedFg: "lightblue"
    selectedBg: "lightblack"
    keys: true
    vi: true
  filemanager.on "file", (file) ->
    menu filemanager, file

  Otoshibako.$.filer = filemanager

  Otoshibako
    .key filemanager, "~",  -> filemanager.refresh "~", ->
    .key filemanager, "S-d", -> filemanager.refresh expand("~/Desktop"), ->
    .key filemanager, "m", -> Otoshibako.goto "multiSelect"
    .key filemanager, "space", ->
      Otoshibako.multiSelect.add filemanager.getFocusedItem()

  filemanager.refresh()

  Otoshibako.router.on "filer", ->
    Otoshibako.exchanger.show "filer"
    Otoshibako.screen.render()

  Otoshibako.exchanger.add "filer", filemanager

  Otoshibako.screen.append filemanager
