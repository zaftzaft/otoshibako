api = require "../lib/api"
QueueLimit = require "../lib/ql"

module.exports = (Otoshibako) ->
  box = Otoshibako.blessed.Box
    top: 1
    bg: "black"
    tags: true
    alwaysScroll: true
    scrollable: true
    keys: true
    vi: true


  Otoshibako.key box, "c", -> Otoshibako.back()


  Otoshibako.router.on "stream", ->
    Otoshibako.exchanger.show "stream"
    Otoshibako.screen.render()

  Otoshibako.exchanger.add "stream", box
  Otoshibako.screen.append box
  box.resetScroll()

  index = 0
  Otoshibako.download = (from, to) ->
    box.append Otoshibako.blessed.Text
      tags: true
      bg: "black"
      top: index++
      content: "{yellow-fg}#{from}{/yellow-fg} -> {green-fg}#{to}{/green-fg}"
    bar = Otoshibako.blessed.ProgressBar
      top: index++
      style:
        bg: "black"
        bar: bg: "light-blue"
      height: 1
    box.append bar
    index++

    api.files from, to, (w, l) ->
      bar.setProgress (w / l) * 100
      Otoshibako.screen.render()
    , (err, filename) ->


  uploadQueue = new QueueLimit 1
  Otoshibako.upload = (from, to) ->
    box.append Otoshibako.blessed.Text
      tags: true
      bg: "black"
      top: index++
      content: "{green-fg}#{from}{/green-fg} => {yellow-fg}#{to}{/yellow-fg}"
    bar = Otoshibako.blessed.ProgressBar
      top: index++
      style:
        bg: "black"
        bar: bg: "light-blue"
      height: 1
    box.append bar
    index++

    uploadQueue.push (next) ->
      api.filesPut to, from, (data) ->
        next()
        bar.setProgress 100
        Otoshibako.screen.render()


