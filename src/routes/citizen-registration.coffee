express = require 'express'
router  = express.Router()

citizen = require '../user/citizen'

router.all '/', (req, res, next) ->
  res.locals.attr_list = citizen.attr_list
  res.locals.today = new Date().toISOString().slice(0, 10)
  next()
  return

module.exports = router