eaw = require "eastasianwidth"

byteFormat = (bytes) ->
  kib = 1 << 10
  mib = 1 << 20
  gib = 1 << 30
  return (
    if bytes > gib
      "#{(bytes / gib).toFixed 1}GB"
    else if bytes > mib
      "#{(bytes / mib).toFixed 1}MB"
    else if bytes > kib
      "#{(bytes / kib).toFixed 1}KB"
    else
      "#{bytes}B"
  )


dateFormat = (modified) ->
  p = (n) -> if n > 9 then n else "0" + n
  d = new Date modified
  dy = ("" + d.getFullYear()).slice 2
  dm = p d.getMonth() + 1
  da = p d.getDate()
  dh = p d.getHours()
  di = p d.getMinutes()
  ds = p d.getSeconds()
  return "#{dy}/#{dm}/#{da} #{dh}:#{di}:#{ds}"


printFormat = (width, name, bytes, modified) ->
    byte = byteFormat bytes
    byte = new Array(8 - byte.length + 1).join(" ") + byte
    date = dateFormat modified
    right = "#{byte} #{date}"
    w = width - right.length

    len = eaw.length(name
      .replace /\{\/?[\w\-]+\}/g, ""
      .replace /\x1b\[[\d;]*m/g, ""
    )

    if len > w
      name = "#{name.slice(0, w - 3)}.."
    else
      name = name + new Array(w - len).join " "

    return "#{name} #{right}"


sort = (contents) ->
  result = contents.reduce (o, a) ->
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

  return [].concat result.dir, result.file


module.exports = {
  dateFormat: dateFormat
  byteFormat: byteFormat
  printFormat: printFormat
  sort: sort
}
