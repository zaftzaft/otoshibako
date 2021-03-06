ls  = require "../lib/ls"
mkdir = require "./mkdir"
rename = require "./rename"
deletef = require "./delete"
{expand} = require "../lib/paths"
utils  = require "../lib/utils"

module.exports = (Otoshibako) ->
  menu = (data) ->
    el = Otoshibako.blessed.Box
      width: "80%"
      height: "80%"
      left: "center"
      top: "center"
      bg: "black"
      border:
        type: "line"
        fg: "blue"
        bg: "black"

    Otoshibako.screen.append el

    #el.setContent data.path
    el.setLine 0, data.path
    el.setLine 1, Otoshibako.byteFormat data.bytes
    el.setLine 2, Otoshibako.dateFormat data.modified
    el.append Otoshibako.blessed.Text
      content: "c: Close, d: Download, e: Rename, x: Delete"
      left: 1
      right: 1
      bottom: 0
      bg: "blue"
    el.focus()

    Otoshibako
      .key el, "c", -> el.detach(); Otoshibako.screen.render()
      .key el, "d", ->
        Otoshibako.download data.path, expand("~/Desktop")
        Otoshibako.goto "stream"
      .key el, "e", -> rename Otoshibako, data.path
      .key el, "x", -> deletef Otoshibako, data

    Otoshibako.screen.render()
    return el


  updateStatus = (dir = "", hash = "") ->
    status = Otoshibako.$.status
    dir = Otoshibako.pwd
    status.setContent "r: Reload, h: Help  | #{dir} | #{hash}"


  chdir = (url, useCache = true) ->
    ls url, useCache, (err, res) ->
      updateStatus res.path, res.hash
      list.clearItems()

      if url isnt "" and url isnt "/"
        list.add "../"
        el = list.items.slice(-1)[0]
        el.data = {
          path: res.path.split("/").slice(0, -1).join("/") || "/"
          is_dir: true
        }

      utils
        .sort res.contents
        .forEach (a) ->
          name = a.path.split("/").pop()
          if a.is_dir
            name = "{light-magenta-fg}#{name}/{/light-magenta-fg}"
          list.add Otoshibako.print(name, a.bytes, a.modified)
          el = list.items.slice(-1)[0]
          el.data = a

      Otoshibako.screen.render()


  list = Otoshibako.blessed.list
    top: 1
    tags: true
    style:
      bg: "black"
      selected:
        bg: "blue"
      item:
        bg: "black"
    keys: true
    vi: true

  Otoshibako.$.dropbox = list

  Otoshibako
    .key list, "r", -> chdir Otoshibako.pwd, false
    .key list, "m", -> mkdir(Otoshibako)

  list.on "select", (item, selected) ->
    if item.data.is_dir
      Otoshibako.goto "dropbox#{item.data.path}"
    else
      menu item.data
      #list.append menu item.data
      #Otoshibako.screen.append menu item.data
      #Otoshibako.screen.render()


  Otoshibako.router.on "dropbox(.*)", (url) ->
    Otoshibako.exchanger.show "dropbox"

    unless url
      return Otoshibako.screen.render()

    Otoshibako.pwd = url

    chdir url


  Otoshibako.exchanger.add "dropbox", list


  Otoshibako.screen.append list
  Otoshibako.goto "dropbox/"

