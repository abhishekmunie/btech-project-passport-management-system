crypto = require 'crypto'

user = require './user'

globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect

EntityName = '"passport"."ValidationAuthority"'

TYPE = 'ValidationAuthority'

class ValidationAuthority extends user.User

  constructor: (@email, @name) ->
    @type = TYPE

isValidationAuthority = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "is_validation_authority"
      text: "SELECT count(*) AS exists FROM #{EntityName} WHERE email = $1::varchar"
      values: [email]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, result.rows[0].exists is '1'

getForEmail = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "get_validation_authority_for_email"
      text: "SELECT * FROM #{EntityName} WHERE email = $1::varchar"
      values: [email]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      if result.rows[0]
        callback? null, new ValidationAuthority(result.rows[0].email, result.rows[0].Name)
      else
        callback? null, null


insertQuery = (values, client, done, callback) ->
  client.query
    name: "va_insert"
    text: "INSERT INTO #{EntityName} VALUES ( $1::varchar , $2::varchar , $3::int ) "
    values: values
  , (err, result) ->
    if err
      done? client
      callback? err
      return
    done?()
    callback? null, result.rows

insertValidationAuthorityIntoDatabase = (email, Name, regionId, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    insertQuery [email, Name, regionId], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        callback? err
        return
      insertQuery [email, Name, regionId], client, done, callback
      return
  return

addValidationAuthority = (email, Name, regionId, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined
  debug "Adding VA with email: #{email}"
  tempPassword = crypto.createHash('sha1').update(crypto.randomBytes 256).digest 'hex'
  user.addUser email, tempPassword, client, (err) ->
    user.resetPasswordForUserWithEmail email, client, (err, res) ->
      return callback? err if err
      console.log 'ok'
      insertValidationAuthorityIntoDatabase email, Name, regionId, client, callback
      return
    return
  return

rollback = (client, done) -> client.query 'ROLLBACK', (err) -> done? err

addVAForRegionId = (email, regionId, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query 'BEGIN', (err) ->
      if err
        rollback client, done
        callback? err
        return
      addValidationAuthority email, "A Validation Authority of Region #{regionId}", regionId, client, (err) ->
        if err
          rollback client, done
          callback? err
          return
        client.query 'COMMIT', (err) ->
          if err
            done? client
            callback? err
            return
          done?()
          callback?()
          return
        return
      return
    return
  return


deleteQuery = (email, client, done, callback) ->
  client.query
    name: "va_delete"
    text: "DELETE FROM #{EntityName} WHERE \"email\" = $1::varchar "
    values: [email]
  , (err, result) ->
    if err
      done? client
      callback? err
      return
    done?()
    callback? null, result.rows

deleteValidationAuthorityFromDatabase = (email, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    insertQuery email, client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        callback? err
        return
      insertQuery email, client, done, callback
      return
  return

removeValidationAuthority = (email, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined
  debug "Removing PGO with email: #{email}"
  deleteValidationAuthorityFromDatabase email, client, (err) ->
    user.removeUser email, client, callback


removeVAWthEmail = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query 'BEGIN', (err) ->
      if err
        rollback client, done
        callback? err
        return
      removeValidationAuthority email, client, (err) ->
        if err
          rollback client, done
          callback? err
          return
        client.query 'COMMIT', (err) ->
          if err
            done? client
            callback? err
            return
          done?()
          callback? null, result.rows
          return
        return
      return
    return
  return

filter = (req, res, next) ->
  debug "Validation Authority Auth Filter: #{req.url}"
  return res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}" unless req.session.user
  isValidationAuthority req.session.user.email, (err, vaValidity) ->
    unless vaValidity
      if req.session.user
        if req.session.user.type is TYPE
          req.session.user = null
          return res.redirect "/auth/signin"
        else
          return res.redirect "/dashboard"
      else
        req.url = "/auth/signin/va"
    next()
  return

module.exports =
  ValidationAuthority: ValidationAuthority
  type: TYPE
  EntityName: EntityName

  filter: filter
  isValidationAuthority: isValidationAuthority
  getForEmail: getForEmail
  addVAForRegionId: addVAForRegionId
  addValidationAuthority: addValidationAuthority
