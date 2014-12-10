fs    = require "fs"
path  = require "path"
api   = require "./api"
paths = require "./paths"

class Index
  fp: paths.index

  constructor: ->
    if fs.existsSync @fp
      @collection = JSON.parse fs.readFileSync(@fp, "utf8")
    else
      @collection = {}

  update: (cpath, hash) =>
    if old = @collection[cpath]
      if old isnt hash
        fs.unlink path.join(paths.cache, "#{old}.json")

    @collection[cpath] = hash
    @save()

  get: (cpath) =>
    @collection[cpath] || null

  save: =>
    fs.writeFile @fp, JSON.stringify @collection

class Cache
  constructor: ->
    @index = new Index

  get: (cpath, callback) =>
    hash = @index.get cpath
    if hash
      fp = path.join paths.cache, "#{hash}.json"
      fs.readFile fp, "utf8", (err, data) ->
        return callback err if err
        callback null, JSON.parse data
    else
      callback new Error "Cache Not Found"

  set: (cpath, data) =>
    #json = JSON.parse data
    hash = data.hash
    fp = path.join paths.cache, "#{hash}.json"
    fs.writeFile fp, JSON.stringify data
    @index.update cpath, hash


cache = new Cache
module.exports = (cpath = "/", useCache = true, callback) ->
  cpath = "/" if cpath is ""

  fetch = ->
    api.metadata cpath, (err, result) ->
      return callback err if err
      cache.set cpath, result
      callback null, result

  unless useCache
    return do fetch

  cache.get cpath, (err, result) ->
    return do fetch if err
    callback null, result
