api = require "../lib/api"

module.exports = (Otoshibako, data) ->
  confirm = Otoshibako.blessed.Box
    width: "50%"
    height: "50%"
    left: "center"
    top: "center"
    bg: "black"
    tags: true
    border:
      type: "line"
      fg: "red"
      bg: "black"

  disable = -> confirm.detach(); Otoshibako.screen.render()

  confirm.key "y", ->
    api.delete data.path, ->
      disable()
  confirm.key "n", disable

  confirm.setContent " delete #{data.path}  y/n"
  confirm.focus()

  Otoshibako.screen.append confirm
  Otoshibako.screen.render()
