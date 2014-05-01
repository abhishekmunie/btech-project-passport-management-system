async   = require 'async'
express = require 'express'
router  = express.Router()

pgo     = require '../user/pgo'
va      = require '../user/va'

globals = require '../globals'

region = require '../passport/region'


router.post '/va-management', (req, res, next) ->
  action = req.param 'action'
  switch action
    when 'setValidationAuthorityEmail'
      Id = req.param 'Id'
      VAEmail = req.param 'email'
      unless /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/.test VAEmail
        res.locals.error = new Error('Invalid email.')
        next()
        return
      pgo.getRegionIdForPGOWithEmail req.session.user.email, (err, Id) ->
        if err
          res.locals.error = err
          next()
          return
        unless Id
          res.locals.error = new Error('Region Id not found')
          next()
          return
        va.addVAForRegionId VAEmail, Id, (err, row) ->
          if err
            res.locals.error = err
            next()
            return
          res.locals.success = message: "validation Authority's Email was successfully Authorize."
          next()
          return
    when 'unsetValidationAuthorityEmail'
      VAEmail = req.param 'email'
      region.unsetPGOForRegionId Id, (err, row) ->
        if err
          res.locals.error = err
          next()
          return
        console.log row
        res.locals.success = message: "validation Authority's Email was successfully Unauthorize."
        next()
        return
    else
      res.locals.error = new Error('Invalid request.')
      next()
  return

router.all '/va-management', (req, res, next) ->
  pgo.getValidationAuthorititesUnderPGOWithEmail req.session.user.email, (err, vas) ->
    return next err if err
    res.locals.validationAuthorities = vas
    next()
    return
  return

module.exports = router