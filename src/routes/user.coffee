async   = require 'async'
express = require 'express'
router  = express.Router()

citizen = require '../user/citizen'
application = require '../passport/application'
region = require '../passport/region'

# globals = require '../globals'
# PGConnect = globals.PGConnect


router.all '/profile', (req, res, next) ->
  res.locals.attr_list = citizen.attr_list
  application.getAllForEmail req.session.user.email, (err, application) ->
    return next err if err
    res.locals.applications = (application.expandValueUsingMap app for app in applications)
  return

router.all '/application', (req, res, next) ->
  next()

router.all '/application', (req, res, next) ->
  res.locals.attr_list = application.attr_list
  region.getRegions (err, regions) ->
    return next err if err
    res.locals.regions = regions
    next()
    return
  return

module.exports = router