api = require "../lib/api"
ls  = require "../lib/ls"

nameFilter = (name) ->
  name = name.replace "カメラアップロード", "camera upload"
  name = name.split("")
    .map (c) -> if c.charCodeAt() > 127 then '?' else c
    .join ""
  return name

module.exports = (blessed, screen) ->
  updateStatus = (dir = "", hash = "") ->
    status = screen.query "status"
    status.setContent "r: Reload, h: Help  | #{nameFilter dir} | #{hash}"

  print = (name, bytes, modified) ->
    w = screen.width - 28
    if name.length > w
      name = "#{name.slice(0, w - 2)}.."
    else
      t = w - name.length
      name = name + new Array(t + 1).join(" ")


    #TODO この辺をutilsにまとめる
    kib = 1 << 10
    mib = 1 << 20
    gib = 1 << 30
    byte = (
      if bytes > gib
        "#{(bytes / gib).toFixed 1}GB"
      else if bytes > mib
        "#{(bytes / mib).toFixed 1}MB"
      else if bytes > kib
        "#{(bytes / kib).toFixed 1}KB"
      else
        "#{bytes}B"
    )
    byte = new Array(8 - byte.length + 1).join(" ") + byte

    p = (n) -> if n > 9 then n else "0" + n
    d = new Date modified
    dy = ("" + d.getFullYear()).slice 2
    dm = p d.getMonth() + 1
    da = p d.getDate()
    dh = p d.getHours()
    di = p d.getMinutes()
    ds = p d.getSeconds()
    df = "#{dy}/#{dm}/#{da} #{dh}:#{di}:#{ds}"
    return "#{name}#{byte} #{df}"

  # List
  list = blessed.List {
    bg: "black"
    top: 1
    selectedFg: "lightblue"
    selectedBg: "lightblack"
    keys: true
    vi: true
  }
  list.id = "list"
  list.key "r", -> chdir pwd, false # Reload
  list.key "m", -> #mkdir
    disable = ->
      screen.remove box
      screen.render()

    box = blessed.Box
      label: "Create Folder"
      width: "60%"
      height: "30%"
      top: "center"
      left: "center"
      bg: "black"
      border:
        type: "line"
        fg: "yellow"
        bg: "black"

    #text = blessed.Text
    #  content: "Create Folder (c: Close)"
    #  top: 1
    #  left: 1
    #  right: 1
    #  bg: "yellow"

    textbox = blessed.Textbox
      height: 1
      top: 3
      left: 2
      right: 2
      bg: "blue"
      #border:
      #  type: "line"
      #  fg: "blue"
      #  bg: "black"
      key: true

    box.key "c", disable

    #box.append text
    box.append textbox
    screen.append box
    screen.render()

    box.focus()

    setTimeout ->
      textbox.readEditor()
    , 300

    textbox.on "submit", ->
      api.createFolder "#{pwd}/#{textbox.getValue()}", (err, result) ->
        throw err if err
#        console.log result
#        text.setContent "Created!!!! (c: Close)"
        disable()


  list.on "select", (item, selected) ->
    if item.__is_dir
      chdir item.__path
    else
      menu.item = item
      menu.append blessed.Text
        content: "c: Close, d: Download, e: Rename"
        left: 1
        right: 1
        bottom: 1
        bg: "blue"
      menu.show()
      menu.focus()
      screen.render()

  # Menu
  menu = blessed.Box
    width: "70%"
    height: "70%"
    left: "center"
    top: "center"
    bg: "black"
    border:
      type: "line"
      fg: "blue"
      bg: "black"
  menu.id = "menu"

  menu.hide()
  menu.key ["c", "escape"], ->
    menu.hide()
    screen.render()
  menu.key "d", ->
    pb = blessed.ProgressBar {
      orientation: "horizontal"
      #barFg: "blue"
      bg: "lightblue"
      barBg: "blue"
      left: 1
      right: 1
      height: 1
      bottom: 2
      value: 0
    }
    menu.append pb
    #download menu.item.__path, (w, l) ->
    api.files menu.item.__path, (w, l) ->
      pb.setProgress (w / l) * 100
      screen.render()
    , (err, filename) ->
      menu.setLine 3, "Downloaded (#{filename})"
      menu.remove pb
      screen.render()
  menu.key "e", ->
    pathDvd = menu.item.__path.split "/"
    file = pathDvd.pop()
    dir = pathDvd.join("/")

    textbox = blessed.Textbox {
      height: 1
      bg: "cyan"
      key: true
    }
    menu.append textbox
    textbox.setValue file
    textbox.readEditor ->
    textbox.on "submit", ->
      # Rename
      api.move menu.item.__path, "#{dir}/#{textbox.getValue()}", (err, result) ->
        console.log result
        menu.remove textbox
        #screen.render()

  screen.append list
  screen.append menu
  list.focus()

  escapeNonAscii = true
  pwd = ""
  chdir = (p = "", useCache = true) ->
    pwd = p
    list.pwd = p
    ls p, useCache, (err, json) ->
    #ls.get p, useCache, (json) ->
      updateStatus json.path, json.hash
      list.clearItems()

      unless json.contents
        console.log json
        return

      if p isnt "" and p isnt "/"
        list.add "../"
        el = list.items.slice(-1)[0]
        el.__path = json.path.split("/").slice(0, -1).join("/")
        el.__is_dir = true
        el.style.fg = "cyan"

      result = json.contents.reduce (o, a) ->
        if a.is_dir
          o.dir.push a
        else
          o.file.push a
        return o
      , {dir:[], file:[]}

      compare = (a, b) ->
        if a.path.split("/").pop() > b.path.split("/").pop() then 1 else -1
      result.dir = result.dir.sort compare
      result.file = result.file.sort compare

      []
        .concat result.dir, result.file
        .forEach (item) ->
          name = item.path.split("/").pop()
          name = nameFilter name if escapeNonAscii
          list.add name
          el = list.items.slice(-1)[0]
          el.__path = item.path
          el.__is_dir = item.is_dir
          #el.__bytes = item.bytes
          #el.__modified = item.modified
          if item.is_dir
            el.style.fg = "magenta"
            el.setContent "#{name}/"
            #el.style.selected = fg: "blue"
          else
            el.setContent print(name, item.bytes, item.modified)

      screen.render()

  updateStatus()
  chdir()

  list.key ["C-e"], ->
    escapeNonAscii = !escapeNonAscii
    chdir pwd
