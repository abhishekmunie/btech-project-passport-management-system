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
      async.map [admin, pgo, va, citizen]
      , (user, callback) ->
        user.getForEmail email, callback
      , (err, users) ->
        req.session.user = filteredUser for filteredUser in users when filteredUser?
        req.session.user = new user.User(email) unless req.session.user
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
    res.locals.success = message: 'You have been sent a verification email. Please check your inbox/spam and click verify to activate your account.'
    next()
  return

rollback = (client, done) -> client.query 'ROLLBACK', (err) -> done? err

router.all '/verification', (res, req, next) ->
  res.locals.error = new Error('Invalid Verification Link')
  res.locals.hideForm = true
  next()
  return

router.all '/verification/:verificationKey', (req, res, next) ->
  verificationKey = req.param 'verificationKey'
  req.url = '/verification'
  unverifiedUser.getEmailForVerificationKey verificationKey, (err, email) ->
    unless email
      res.locals.error = new Error('Invalid Verification Link')
      res.locals.hideForm = true
      next()
      return
    res.locals.email = email
    res.locals.verificationKey = verificationKey
    res.locals.encodedVerificationKey = encodeURIComponent(verificationKey)
    next()
    return

router.post '/verification', (req, res, next) ->
  if res.locals.error
    next()
    return
  verificationKey = req.param 'verificationKey'
  console.log 'verificationKey', verificationKey
  password = req.param 'password'
  confirmPassword = req.param 'confirmPassword'
  if password isnt confirmPassword
    res.locals.error = new Error('Password and Confirmation Password didn\'t match.')
    next()
    return

  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query 'BEGIN', (err) ->
      if err
        rollback client, done
        res.locals.error = err
        next()
        return
      user.addUser res.locals.email, password, client, (err) ->
        if err
          rollback client, done
          res.locals.error = err
          next()
          return
        unverifiedUser.removeUnverifiedUser verificationKey, client, (err) ->
          if err
            rollback client, done
            res.locals.error = err
            next()
            return
          client.query 'COMMIT', (err) ->
            if err
              done? client
              res.locals.error = err
              next()
              return
            done?()
            req.session.user = new user.USER(res.locals.email)
            if req.param 'redirect'
              res.redirect req.param 'redirect'
            else
              res.redirect '/dashboard/'


# router.all '/reset', (req, res, next) ->
#   verificationKey = req.param 'verificationKey'
#   if not verificationKey or verificationKey is ''
#     res.locals.error = new Error('Invalid Verification Link')
#     res.locals.hideForm = true
#     next()
#     return
#   unverifiedUser.getEmailForVerificationKey verificationKey, (err, email) ->
#     unless email
#       res.locals.error = new Error('Invalid Verification Link')
#       res.locals.hideForm = true
#       next()
#       return
#     res.locals.email = email
#     res.locals.verificationKey = verificationKey
#     next()
#     return

# router.post '/reset', (req, res, next) ->
#   if res.locals.error
#     next()
#     return
#   verificationKey = req.param 'verificationKey'
#   password = req.param 'password'
#   confirmPassword = req.param 'confirmPassword'
#   if password isnt confirmPassword
#     res.locals.error = new Error('Password and Confirmation Password didn\'t match.')
#     next()
#     return

#   PGConnect (err, client, done) ->
#     if err
#       done? client
#       callback? err
#       return
#     client.query 'BEGIN', (err) ->
#       if err
#         rollback client, done
#         res.locals.error = err
#         next()
#         return
#       user.addUser res.locals.email, password, client, (err) ->
#         if err
#           rollback client, done
#           res.locals.error = err
#           next()
#           return
#         unverifiedUser.removeUnverifiedUser verificationKey, client, (err) ->
#           if err
#             rollback client, done
#             res.locals.error = err
#             next()
#             return
#           client.query 'COMMIT', (err) ->
#             if err
#               done? client
#               res.locals.error = err
#               next()
#               return
#             done?()
#             if req.param 'redirect'
#               res.redirect req.param 'redirect'
#             else
#               res.redirect '/dashboard/'

module.exports = router
