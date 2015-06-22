module.exports = (Shell) ->
  Shell.more = (textAry, cb) ->
    row = process.stdout.rows
    if textAry.length > row
      Shell.chmode "more"
      do ->
        index = 0
        Shell.more.fn = ->
          textAry
            .slice index, index + row
            .forEach (text) ->
              process.stdout.write text
          index += row
          if index > textAry.length
            Shell.more.fn = ->
            Shell.chmode Shell.before
            cb null
      Shell.more.fn()
    else
      textAry.forEach (text) ->
        process.stdout.write text
      cb null


  Shell.decomposer = (line) ->
    ary = []
    index = 0
    f = false
    i = 0
    ary[index] = ""
    while c = line[i++]
      if c is "\""
        f = !f
        continue
      else if !f and c is " "
        index++
        ary[index] = ""
        continue

      ary[index] += c

    return ary
