user = require './user'

globals = require '../globals'
PGConnect = globals.PGConnect

EntityName = '"passport"."ValidationAuthority"'

TYPE = 'ValidationAuthority'

class ValidationAuthority extends user.User

  constructor: (@email, @name) ->
    @type = TYPE

module.exports =
  ValidationAuthority: ValidationAuthority
  type: TYPE

  filter: (req, res, next) ->
    debug "Validation Authority Auth Filter: #{req.url}"
    req.url = "/auth/signin/va" unless req.session.user? and req.session.user.type is TYPE
    next()

  isValidationAuthority: (email, callback) ->
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      client.query
        name: "is_validation_authority"
        text: "SELECT count(*) AS exists FROM #{EntityName} WHERE email = $1::varchar"
        values: [email]
      , (err, result) ->
        if err
          done? client
          console.error 'error running query', err
          callback? err
          return
        done?()
        callback? null, result.rows[0].exists is '1'

  getForEmail: (email, callback) ->
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      client.query
        name: "get_validation_authority_for_email"
        text: "SELECT * FROM #{EntityName} WHERE email = $1::varchar"
        values: [email]
      , (err, result) ->
        if err
          done? client
          console.error 'error running query', err
          callback? err
          return
        done?()
        if result.rows[0]
          callback? null, new ValidationAuthority(result.rows[0].email, result.rows[0].Name)
        else
          callback? null, null
