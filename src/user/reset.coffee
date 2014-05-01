crypto = require 'crypto'
appCrypto = require '../crypto'

globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect
emailClient = require '../email'

EntityName = '"passport"."ResetKey"'

class Reset

  constructor: (@email, @resetKey) ->


insertQuery = (values, client, done, callback) ->
  client.query
    name: "reset_insert"
    text: "INSERT INTO #{EntityName} VALUES ( $1::varchar , $2::varchar ) "
    values: values
  , (err, result) ->
    if err
      done? client
      callback? err
      return
    done?()
    callback?()

insertIntoDatabase = (email, resetKey, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    insertQuery [resetKey, email], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        callback? err
        return
      insertQuery [resetKey, email], client, done, callback
      return
  return

addResetKeyForEmail = (email, name, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined
  crypto.randomBytes 64, (ex, buf) ->
    return callback? ex if ex
    # resetKey = crypto.createHash('sha256').update(buf).digest 'base64'
    resetKey = buf.toString 'base64'
    insertIntoDatabase email, resetKey, client, (err) ->
      return callback? err if err
      to = if name then "#{name} <#{email}>" else email
      emailClient.sendPasswordResetEMail to, resetKey, callback

getEmailForResetKey = (resetKey, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "reset_get_for_key"
      text: "SELECT email FROM #{EntityName} WHERE \"resetKey\" = $1::varchar "
      values: [resetKey]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, if result.rows[0] then result.rows[0].email else null

verifyResetKey = (email, resetKey, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "reset_verification"
      text: "SELECT count(*) AS exists FROM #{EntityName} WHERE \"email\" = $1::varchar AND \"resetKey\" = $2::varchar "
      values: [email, resetKey]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, result.rows[0].exists is '1'

deleteQuery = (values, client, done, callback) ->
  console.log values
  client.query
    name: "reset_delete"
    text: "DELETE FROM #{EntityName} WHERE \"resetKey\" = $1::varchar "
    values: values
  , (err, result) ->
    if err
      done? client
      callback? err
      return
    done?()
    callback?()

deleteFromDatabaseResetKey = (resetKey, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    deleteQuery [resetKey], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        callback? err
        return
      deleteQuery [resetKey], client, done, callback
      return
  return

removeResetKey = (resetKey, client, callback) ->
  console.log resetKey
  deleteFromDatabaseResetKey resetKey, client, callback

module.exports =
  Reset: Reset

  addResetKeyForEmail: addResetKeyForEmail
  getEmailForResetKey: getEmailForResetKey
  verifyResetKey: verifyResetKey
  removeResetKey: removeResetKey
