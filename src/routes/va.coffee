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
    console.log applications
    next()
    return
  return

module.exports = router