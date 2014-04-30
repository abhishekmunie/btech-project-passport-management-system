path    = require 'path'
async   = require 'async'
express = require 'express'
pg      = require 'pg'
router  = express.Router()

globals = require '../globals'
debug = globals.debug

region = require '../passport/region'

postgrator = require 'postgrator'
postgrator.config.set
  migrationDirectory: path.resolve __dirname, '../../sql'
  driver: postgrator.pg,
  connectionString: globals.config.pg_url

admin   = require '../user/admin'

router.post '/reset', (req, res, next) ->
  postgrator.migrate '000', (err, migrations) ->
    if err
      console.error err
      res.locals.error = err
      next()
      return
    debug migrations
    postgrator.migrate '001', (err, migrations) ->
      if err
        console.error err
        res.locals.error = err
        next()
        return
      debug migrations
      res.locals.success =
        message: "App was successfully reset"
      next()
      return
    return
  return

router.post '/pgo-management', (req, res, next) ->
  action = req.param 'action'
  switch action
    when 'setGrantingOfficerEmail'
      Id = req.param 'Id'
      GrantingOfficerEmail = req.param 'GrantingOfficerEmail'
      unless /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/.test GrantingOfficerEmail
        res.locals.error = new Error('Invalid email.')
        next()
        return
      region.setPGOForRegionId Id, GrantingOfficerEmail, (err, row) ->
        return next err if err
        res.locals.success = message: "Granting Officer's Email was successfully Authorize."
        next()
        return
    when 'unsetGrantingOfficerEmail'
      Id = req.param 'Id'
      region.unsetPGOForRegionId Id, (err, row) ->
        return next err if err
        console.log row
        res.locals.success = message: "Granting Officer's Email was successfully Unauthorize."
        next()
        return
    else
      res.locals.error = new Error('Invalid request.')
      next()
  return

router.all '/pgo-management', (req, res, next) ->
  region.getRegions (err, regions) ->
    return next err if err
    res.locals.regions = regions
    next()
    return
  return

module.exports = router
