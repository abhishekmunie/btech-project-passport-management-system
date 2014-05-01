express = require 'express'
router  = express.Router()

citizen = require '../user/citizen'

router.post '/', (req, res, next) ->
  newCitizen = new citizen.Citizen('req', req)
  citizen.addCitizen newCitizen, (err) ->
    if err
      res.locals.error = err
      console.error err
      next()
      return
    req.session.user = newCitizen
    res.redirect "/dashboard"
    return
  return

router.all '/', (req, res, next) ->
  res.locals.attr_list = citizen.attr_list
  res.locals.today = new Date().toISOString().slice(0, 10)
  next()
  return

module.exports = router