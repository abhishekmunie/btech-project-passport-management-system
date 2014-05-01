fs              = require 'fs'
path            = require 'path'

resolve         = require 'resolve-path'
hogan           = require 'hogan.js'
ejs             = require 'ejs'

globals = require './globals'

config = globals.config

cache = {}

renderEJS = (template, req, res) ->
  template
    url: req.url
    encodedUrl: encodeURIComponent(req.url)
    originalUrl: req.originalUrl
    encodedOriginalUrl: encodeURIComponent(req.originalUrl)
    query: req.query
    param: req.params
    session: req.session
    locals: res.locals

renderHogan = (template, req, res) ->
  template.render
    url: req.url
    encodedUrl: encodeURIComponent(req.url)
    originalUrl: req.originalUrl
    encodedOriginalUrl: encodeURIComponent(req.originalUrl)
    url: req.url
    originalUrl: req.originalUrl
    query: req.query
    param: req.params
    session: req.session
    locals: res.locals

module.exports.sendHogan = (url, req, res, callback) ->
  if arguments.length is 3
    # assignmet order is important as assignments change arguments
    callback = arguments[2]
    res = arguments[1]
    req = arguments[0]
    url = req.url
  [urlPath, query] = url.split '?'
  if cache[urlPath]?
    res.send renderHogan cache[urlPath], req, res
    process.nextTick -> callback if typeof callback is "function"
  else
    filename = resolve path.join config.views_dir, urlPath
    fs.readFile filename, (err, data) ->
      return callback? err if err
      if config.env is 'production'
        res.send renderHogan cache[urlPath] = hogan.compile(data.toString()), req, res
      else
        res.send renderHogan hogan.compile(data.toString()), req, res
      callback?()
  return


module.exports.sendEJS = (url, req, res, callback) ->
  if arguments.length is 3
    # assignmet order is important as assignments change arguments
    callback = arguments[2]
    res = arguments[1]
    req = arguments[0]
    url = req.url
  [urlPath, query] = url.split '?'
  if cache[urlPath]?
    res.send renderEJS cache[urlPath], req, res
    process.nextTick -> callback if typeof callback is "function"
  else
    filename = resolve path.join config.views_dir, urlPath
    fs.readFile filename, (err, data) ->
      return callback? err if err
      hoganTemplate = hogan.compile data.toString()
      cache[urlPath] = hoganTemplate if config.env is 'production'
      ejsTemplate = ejs.compile renderHogan(hoganTemplate, req, res),
        cache: config.env is 'production'
        filename: filename
        compileDebug: config.env isnt 'production'
      res.send renderEJS ejsTemplate, req, res
      callback?()
  return
