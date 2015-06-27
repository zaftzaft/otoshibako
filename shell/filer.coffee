paths = require "../lib/paths"

module.exports = (Shell) ->
  Shell.mode "filer"
  Shell.filerDir = paths.expand "~"
