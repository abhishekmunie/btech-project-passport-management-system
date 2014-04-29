async   = require 'async'
express = require 'express'
router  = express.Router()

pgo     = require '../user/pgo'

# globals = require '../globals'
# PGConnect = globals.PGConnect

module.exports = router