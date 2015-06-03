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

module.exports = (Otoshibako) ->
  Otoshibako.byteFormat = byteFormat
  Otoshibako.dateFormat = dateFormat

  Otoshibako.print = (name, bytes, modified) ->
    byte = byteFormat bytes
    byte = new Array(8 - byte.length + 1).join(" ") + byte
    date = dateFormat modified
    right = "#{byte} #{date}"
    w = Otoshibako.screen.width - right.length
    len = eaw.length name.replace /\{\/?[\w\-]+\}/g, ""
    if len > w
      name = "#{name.slice(0, w - 2)}.."
    else
      name = name + new Array(w - len).join " "

    return "#{name} #{right}"
