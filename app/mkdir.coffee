api = require "../lib/api"

module.exports = (Otoshibako) ->
  el = Otoshibako.blessed.Box
    label: "Create Folder (c: Close)"
    width: "70%"
    height: "50%"
    top: "center"
    left: "center"
    bg: "black"
    border:
      type: "line"
      fg: "yellow"
      bg: "black"

  textbox = Otoshibako.blessed.Textbox
    height: 1
    top: 1
    left: 2
    right: 2
    bg: "blue"
    key: true

  textbox.on "submit", ->
    api.createFolder "#{Otoshibako.pwd}/#{textbox.getValue()}", (err, result) ->
      throw err if err
      disable()

  el.append textbox
  Otoshibako.screen.append el
  Otoshibako.screen.render()

  disable = -> el.detach(); Otoshibako.screen.render()

  el.focus()
  el.key "c", disable
  setTimeout (-> textbox.readEditor()), 300

