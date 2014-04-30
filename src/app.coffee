fs              = require 'fs'
url             = require 'url'
path            = require 'path'
http            = require 'http'
zlib            = require 'zlib'
util            = require 'util'
crypto          = require 'crypto'

express         = require 'express'
session         = require 'express-session'
favicon         = require 'static-favicon'
logger          = require 'morgan'
cookieParser    = require 'cookie-parser'
bodyParser      = require 'body-parser'
serveStatic     = require 'serve-static'
resolve         = require 'resolve-path'

pg              = require 'pg'
connectPGSimple = require 'connect-pg-simple'
hogan           = require 'hogan.js'
ejs             = require 'ejs'
cachelicious    = require 'cachelicious'

template        = require './template'

cacheliciousConnect = cachelicious.connect

globals = require './globals'
config = globals.config
debug = globals.debug

app = express()
app.set 'env', config.env
app.set 'ip', config.ip
app.set 'port', config.port

# staticCache = cacheliciousConnect config.static_file.source, maxCacheSize: config.static_file.cache_size
staticCache = serveStatic config.static_file.source

app.use favicon path.join 'static', 'favicon.ico'
app.use logger immediate: true, format: 'dev' if app.get('env') is 'development'
app.enable 'trust proxy' if config.trust_proxy
app.use cookieParser config.cookie_secret
if config.force_https.enable is true
  app.use (req, res, next) ->
    unless req.secure or req.headers['x-forwarded-proto'] is 'https'
      return res.redirect 301, "https://#{config.force_https.host or req.headers.host}#{req.url}"
    res.set 'Strict-Transport-Security': "max-age=#{config.force_https.maxAge}#{config.force_https.includeSubdomains ? "; includeSubDomains" : ""}"
    res.removeHeader 'X-Powered-By'
    next()
    return
app.use bodyParser.json()
app.use bodyParser.urlencoded()


pgSession = connectPGSimple session: session
config.session.config.store = new pgSession(
  pg: pg
  conString: config.pg_url
)
app.use session config.session.config

## static content handler
app.use (req, res, next) ->
  debug "Cachelicious Handler: #{req.url}"
  return next() if req.url[1] is '_' or /^\/(.*\/_.*|node_modules\/.*|package.json|Procfile|vendor\/.*)$/.test req.url
  # req.url = req.url.replace /^(.+)\.(\d+)\.(js|css|png|jpg|gif)$/, '$1.$3' if config.cache_busting
  return staticCache.apply @, arguments

app.all /\.(html|htm|xml|xhtml|xht)$/, (req, res, next) ->
  res.redirect req.url.replace new RegExp("\\/#{config.index}\.(html|htm|xml|xhtml|xht|ejs)"), "/"

app.use '/',                     require './routes/root'
app.use '/auth',                 require './routes/auth'
app.use '/admin',                require './routes/admin'
app.use '/pgo',                  require './routes/pgo'
app.use '/va',                   require './routes/va'
app.use '/user',                 require './routes/user'
app.use '/citizen-registration', require './routes/citizen-registration'

app.all /.*\/[^\.\/]*$/, (req, res, next) ->
  debug "/ Handler: #{req.url}"
  [urlPath, query] = req.url.split '?'
  req.url = "#{path.join urlPath, "#{config.index}.html"}#{if query then "?#{query}" else ""}"
  next()
  return

app.all /\.(html|htm|xml|xhtml|xht)$/, (req, res, next) ->
  debug "Hogan Handler: #{req.url}"
  template.sendHogan req, res, (err) ->
    if err
      req.url = req.url.replace new RegExp("\\/#{config.index}\.(html|htm|xml|xhtml|xht)"), "/#{config.index}.ejs"
      return next()
  return

app.all /\.ejs$/, (req, res, next) ->
  debug "EJS Handler: #{req.url}"
  template.sendEJS req, res, (err) ->
    if err
      req.url = req.url.replace new RegExp("\\/#{config.index}\.ejs"), "/"
      return next()
  return

## catch 404 and forwarding to error handler
app.use (req, res, next) ->
  debug "404 Error Handler: #{req.url}"
  err = new Error('File Not Found')
  err.status = 404
  next err

## error handler
app.use (err, req, res, next) ->
  debug "Error Log Handler: #{req.url}"
  console.error err.stack
  next err
  return

if app.get('env') is 'production'
  # production error handler
  # no stacktraces leaked to user
  app.use (err, req, res, next) ->
    res.status err.status || 500
    if req.xhr
      res.send { error: if err.status is 404 then '404 Not Found' else 'Something blew up!' }
    else
      req.url = "/error/#{err.status || 500}.html"
      return staticCache.apply @, [req, res, next]
    return
  app.use (err, req, res, next) ->
    res.send 'Something blew up!'

else
  # development error handler
  # will print stacktrace
  app.use (err, req, res, next) ->
    debug "x Error Handler: #{req.url}"
    res.status err.status || 500
    if req.xhr
      res.send
        message: err.message
        error: err
    else
      # res.write err.stack
      req.url = "/error/#{err.status || 500}.html"
      return staticCache.apply @, [req, res, next]
    return
  app.use (req, res, next) ->
    res.send 'Something blew up!'


console.time 'Server Startup'
if app.get 'ip'
  server = http.createServer(app).listen app.get('port'), app.get('ip'), ->
    console.timeEnd 'Server Startup'
    address = server.address();
    console.log "Listening on port #{address.port}..." if app.get('env') is 'development'
    return
else
  server = http.createServer(app).listen app.get('port'), ->
    console.timeEnd 'Server Startup'
    address = server.address();
    console.log "Listening on port #{address.port}..." if app.get('env') is 'development'
    return
