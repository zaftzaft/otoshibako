fs = require "fs"
api = require "../lib/api"
{expand} = require "../lib/paths"

module.exports = (blessed, screen) ->
  filemanager = blessed.FileManager {
    cwd: "."
    bg: "black"
    top: 1
    selectedFg: "lightblue"
    selectedBg: "lightblack"
    keys: true
    vi: true
  }
  filemanager.id = "filemanager"
  filemanager.hide()
  filemanager.refresh()
  filemanager.on "cd", (file, cwd) ->
  filemanager.on "file", (file) ->
    fs.lstat file, (err, st) ->
      info.file = file
      info.setLine 0, "P: #{file}"
      info.setLine 1, "CT: #{st.ctime}"
      info.setLine 2, "MT: #{st.mtime}"
      info.setLine 3, "S: #{st.size}"
      info.setLine 4, "" # Upload mes
      info.append blessed.Text
        content: "c: Close, u: Upload"
        left: 1
        right: 1
        bottom: 1
        bg: "blue"
      info.show()
      info.focus()
      screen.render()

  filemanager.key "~", -> filemanager.refresh "~", ->
  filemanager.key "S-d", -> filemanager.refresh expand("~/Desktop"), ->

  info = blessed.Box {
    width: "70%"
    height: "50%"
    left: "center"
    top: "center"
    bg: "black"
    border:
      type: "line"
      fg: "blue"
      bg: "black"
  }
  info.hide()
  info.key "c", ->
    info.hide()
    screen.render()
  info.key "u", ->
    pwd = screen.query("list").pwd
    info.setLine 4, "uploading #{info.file} -> #{pwd}"
    # Upload
    api.filesPut pwd, info.file, (err, result) ->
      throw err if err
      info.setLine 4, "finish"
      screen.render()
    screen.render()


  screen.append filemanager
  screen.append info
