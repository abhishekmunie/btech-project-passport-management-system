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

module.exports =
  Admin: Admin
  type: TYPE

  filter: (req, res, next) ->
    debug "Admin Auth Filter: #{req.url}"
    req.url = "/auth/signin/admin" unless req.session.user? and req.session.user.type is TYPE
    next()

  verifyCredentials: (email, password, callback) ->
    if email is config.admin.email
      settings.get 'admin_pass', (err, validPassword) ->
        callback? null, password is validPassword
    else
      process.nextTick -> callback? null, false

  isAdmin: (email, callback) ->
    process.nextTick -> callback? null, email is config.admin.email

  getForEmail: (email, callback) ->
    if email is config.admin.email
      process.nextTick -> callback? null, new Admin(config.admin.email, config.admin.name)
    else
      process.nextTick -> callback? null, null

