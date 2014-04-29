express = require 'express'
router = express.Router()

user    = require '../user/user'
citizen = require '../user/citizen'
admin   = require '../user/admin'
pgo     = require '../user/pgo'
va      = require '../user/va'

globals = require '../globals'
debug = globals.debug

router.all /^\/dashboard/, (req, res, next) ->
  res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}" unless req.session.user
  switch req.session.user.type
    when citizen.type
      res.redirect req.url.replace /^\/dashboard/, "/user"
    when va.type
      res.redirect req.url.replace /^\/dashboard/, "/va"
    when pgo.type
      res.redirect req.url.replace /^\/dashboard/, "/pgo"
    when admin.type
      res.redirect req.url.replace /^\/dashboard/, "/admin"
    when user.type
      res.redirect req.url.replace /^\/dashboard/, "/citizen-registration"
    else
      res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}"
  return

router.all /^\/admin/, admin.filter
router.all /^\/pgo/, pgo.filter
router.all /^\/va/, va.filter
router.all /^\/user/, citizen.filter
router.all /^\/citizen-registration/, (req, res, next) ->
   debug "Citizen Registration Auth Filter: #{req.url}"
   return res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}" unless req.session.user? and req.session.user.type is user.type
   next()

router.get '/login', (req, res, next) ->
  res.redirect req.url.replace /^\/login/, "/auth/signin"
router.get '/signin', (req, res, next) ->
  res.redirect req.url.replace /^\/signin/, "/auth/signin"

router.get '/logout', (req, res, next) ->
  res.redirect req.url.replace /^\/logout/, "/auth/signout"
router.get '/signout', (req, res, next) ->
  res.redirect req.url.replace /^\/signout/, "/auth/signout"

router.get '/register', (req, res, next) ->
  res.redirect req.url.replace /^\/register/, "/auth/signup"
router.get '/signup', (req, res, next) ->
  res.redirect req.url.replace /^\/signup/, "/auth/signup"

router.get '/_dismiss-warning', (req, res, next) ->
  req.session.dont_warn = true
  if req.param 'redirect'
    res.redirect req.param 'redirect'
  else
    res.redirect '/'

module.exports = router