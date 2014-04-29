async   = require 'async'
express = require 'express'
router  = express.Router()

citizen = require '../user/citizen'

# globals = require '../globals'
# PGConnect = globals.PGConnect

module.exports = router