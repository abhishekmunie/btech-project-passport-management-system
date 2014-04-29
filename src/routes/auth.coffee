async   = require 'async'
express = require 'express'
router  = express.Router()

auth           = require '../user/authentication'
user           = require '../user/user'
unverifiedUser = require '../user/unverifiedUser'
citizen        = require '../user/citizen'
admin          = require '../user/admin'
pgo            = require '../user/pgo'
va             = require '../user/va'

globals = require '../globals'
PGConnect = globals.PGConnect

router.post '/signin', (req, res, next) ->
  email = req.param 'email'
  auth.verifyCredentials email, req.param('password'), (err, validity) ->
    return next err if err
    unless validity is true
      res.locals.error = new Error('Invalid Credentials')
      res.locals.error.details = "It looks like this was the result of either: <br /><ul><li>Non-existent user</li><li>a mistyped password</li></ul>"
      res.locals.autoFillUsingLocals = true
      res.locals.email = email
      next()
    else
      user = email: email
      async.map [admin, pgo, va, citizen]
      , (user, callback) ->
        user.getForEmail email, callback
      , (err, users) ->
        console.log users
        req.session.user = user for user in users when user?
        console.log req.session.user
        if req.param 'redirect'
          res.redirect req.param 'redirect'
        else
          res.redirect '/dashboard/'
  return

router.get '/login', (req, res, next) -> res.redirect req.url.replace /^\/login/, "/signin"
router.get '/signin', (req, res, next) ->
  return res.redirect '/dashboard/' if req.session.user
  next()
  return

router.get '/logout', (req, res, next) -> res.redirect req.url.replace /^\/logout/, "/signout"
router.all '/signout', (req, res, next) ->
  return res.redirect '/' unless req.session.user
  req.session.user = null
  res.redirect '/auth/signin'
  return

router.get '/register', (req, res, next) -> res.redirect req.url.replace /^\/login/, "/register"
router.post '/signup', (req, res, next) ->
  email = req.param 'email'
  name = req.param 'name'
  unless /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/.test email
    res.locals.error = new Error('Invalid email.')
    res.locals.autoFillUsingLocals = true
    res.locals.name = name
    res.locals.email = email
    next()
    return
  unverifiedUser.addUnverifiedUser email, name, (err) ->
    if err
      res.locals.error = err
      res.locals.autoFillUsingLocals = true
      res.locals.name = name
      res.locals.email = email
      next()
      return
    res.locals.success = msg: 'You have been sent a verification email. Please check your inbox and click verify to activate your account.'
    next()
  return

router.post '/verification', (req, res, next) ->
  email = req.param 'email'
  verificationKey = req.param 'verificationKey'
  if verificationKey of verificationKey = ''
    res.locals.error = new Error('Invalid Verification Link')
    next()
    return
  unverifiedUser.verifyVerificationKey email, verificationKey, (err, validity) ->
    if err
      res.locals.error = err
      next()
      return
    if validity is true
      if req.param 'redirect'
        res.redirect req.param 'redirect'
      else
        res.redirect '/dashboard/'
    else
      res.locals.error = new Error('Invalid Verification.')
      next()
      return

router.all '/verification', (req, res, next) ->
  verificationKey = req.param 'verificationKey'
  if verificationKey of verificationKey = ''
    res.locals.error = new Error('Invalid Verification Link')
    next()
    return
  unverifiedUser.getEmailForVerificationKey verificationKey, (err, email) ->
    unless email
      res.locals.error = new Error('Invalid Verification Link')
      next()
      return
    res.locals.email = email
    res.locals.verificationKey = verificationKey
    next()
    return

module.exports = router
