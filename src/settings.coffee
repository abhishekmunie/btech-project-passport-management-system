
globals = require './globals'
PGConnect = globals.PGConnect

EntityName = '"public"."Setting"'

module.exports =
  get: (key, callback) ->
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      client.query
        name: "setting_get"
        text: "SELECT value FROM #{EntityName} WHERE key = $1::varchar "
        values: [key]
      , (err, result) ->
        if err
          done? client
          console.error 'error running query', err
          callback? err
          return
        done?()
        callback? null, if result.rows[0] then result.rows[0].value else null

  set: (key, value, callback) ->
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      client.query
        name: "setting_set"
        text: "UPDATE #{EntityName} SET value=$2::varchar where key=$1::varchar "
        values: [key, value]
      , (err, result) ->
        if err
          done? client
          console.error 'error running query', err
          callback? err
          return
        done?()
        callback?()