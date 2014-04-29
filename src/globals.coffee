pg = require 'pg'

configConvict = require './config'
configConvict.validate()
config = configConvict.get()

PGConnect = (callback) ->
  pg.connect config.pg_url, callback

module.exports =
  config: config
  debug: require('debug') 'app'
  PGConnect: PGConnect