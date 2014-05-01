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
  citizen.getForEmail req.session.user.email, (err, citizenData) ->
    return next err if err
    citizen.expandValueUsingMap citizenData
    citizenData[attr] = value.toDateString() for attr, value of citizenData when value instanceof Date
    res.locals.citizen = citizenData
    next()
    return
  return

router.all '/status', (req, res, next) ->
  res.locals.attr_list = citizen.attr_list
  application.getAllForEmail req.session.user.email, (err, applications) ->
    return next err if err
    res.locals.applications = (application.expandValueUsingMap app for app in applications)
    next()
    return
  return

router.post '/application', (req, res, next) ->
  newApplication = new application.Application('req', req)
  application.addApplication newApplication, (err) ->
    if err
      res.locals.error = err
      console.error err
      next()
      return
    res.locals.success = message: 'You passport request has been successfully registered.'
    next()
    return
  return
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