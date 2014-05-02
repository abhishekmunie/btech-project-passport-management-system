async   = require 'async'
express = require 'express'
router  = express.Router()

citizen      = require '../user/citizen'
va      = require '../user/va'
application = require '../passport/application'

globals = require '../globals'

router.all '/application/list', (req, res, next) ->
  va.getApplicationsWithProfileForVAWithEmail req.session.user.email, (err, applications) ->
    return next err if err
    for app in applications
      application.expandValueUsingMap app
      citizen.expandValueUsingMap app
    res.locals.applications = applications
    next()
    return
  return

router.all '/application/details/:Id', (req, res, next) ->
  applicationId = req.param 'Id'
  application.getApplicationsWithProfileForId applicationId, (err, applicationForId) ->
    return next err if err
    application.expandValueUsingMap applicationForId
    citizen.expandValueUsingMap applicationForId
    res.locals.application = applicationForId
    req.url = '/application/details/'
    next()
    return
  return

module.exports = router