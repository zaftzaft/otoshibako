class QueueLimit
  constructor: (@limit) ->
    @running = 0
    @tasks = []

  next: =>
    @running--
    if @tasks.length
      @tasks.shift() @next

  push: (callback) =>
    if @running < @limit
      @running++
      callback @next
    else
      @tasks.push callback

module.exports = QueueLimit
