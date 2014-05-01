user = require './user'

globals = require '../globals'
debug = globals.debug
config = globals.config
PGConnect = globals.PGConnect

settings = require '../settings'

TYPE ='Admin'

class Admin extends user.User

  constructor: (@email, @name) ->
    @type = TYPE

verifyCredentials = (email, password, callback) ->
  if email is config.admin.email
    settings.get 'admin_pass', (err, validPassword) ->
      callback? null, password is validPassword
  else
    process.nextTick -> callback? null, false

isAdmin = (email, callback) ->
  process.nextTick -> callback? null, email is config.admin.email

getForEmail = (email, callback) ->
  if email is config.admin.email
    process.nextTick -> callback? null, new Admin(config.admin.email, config.admin.name)
  else
    process.nextTick -> callback? null, null

filter = (req, res, next) ->
  debug "Admin Auth Filter: #{req.url}"
  res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}" unless req.session.user
  isAdmin req.session.user.email, (err, adminValidity) ->
    unless adminValidity
      if req.session.user
        res.redirect "/auth/signin"
      else
        res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}"
    next()

module.exports =
  Admin: Admin
  type: TYPE

  filter: filter
  verifyCredentials: verifyCredentials
  isAdmin: isAdmin
  getForEmail: getForEmail

