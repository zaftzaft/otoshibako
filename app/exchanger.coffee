class Exchanger
  constructor: ->
    @elements = {}
    @current = null
    @previous = null

  add: (name, el) ->
    @elements[name] = el
    el.hide()

  show: (name) ->
    @previous = @current
    @current = name
    Object
      .keys @elements
      .forEach (key) => @elements[key].hide()

    @elements[name].show()
    @elements[name].focus()

module.exports = Exchanger

