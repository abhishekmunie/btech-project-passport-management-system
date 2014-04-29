crypto = require 'crypto'
appCrypto = require '../crypto'

globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect
emailClient = require '../email'

EntityName = '"passport"."UnverifiedUser"'
TYPE = 'UnverifiedUser'

class UnverifiedUser

  constructor: (@email) ->
    @type = TYPE


insertQuery = (values, client, done, callback) ->
  client.query
    name: "unverifieduser_insert"
    text: "INSERT INTO #{EntityName} VALUES ( $1::varchar , $2::varchar ) "
    values: values
  , (err, result) ->
    if err
      done? client
      console.error 'error running query', err
      callback? err
      return
    done?()
    callback?()

insertIntoDatabase = (email, verificationKey, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    insertQuery [email, verificationKey], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      insertQuery [email, verificationKey], client, done, callback
      return
  return

getEmailForVerificationKey = (verificationKey, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "unverifieduser_verification"
      text: "SELECT email FROM #{EntityName} WHERE \"VerificationKey\" = $1::varchar "
      values: [verificationKey]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, if result.rows[0] then result.rows[0].email else null

verifyVerificationKey = (email, verificationKey, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "unverifieduser_verification"
      text: "SELECT count(*) AS exists FROM #{EntityName} WHERE \"email\" = $1::varchar AND \"VerificationKey\" = $2::varchar "
      values: [email, verificationKey]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      console.log email, verificationKey, result
      callback? null, result.rows[0].exists is '1'

addUnverifiedUser = (email, name, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined
  crypto.randomBytes 64, (ex, buf) ->
    return callback? ex if ex
    # verificationKey = crypto.createHash('sha256').update(buf).digest 'base64'
    verificationKey = buf.toString 'base64'
    insertIntoDatabase email, verificationKey, client, (err) ->
      return callback? err if err
      to = if name then "#{name} <#{email}>" else email
      emailClient.sendVerificationEMail to, verificationKey, callback

deleteQuery = (values, client, done, callback) ->
  client.query
    name: "unverifieduser_delete"
    text: "DELETE FROM #{EntityName} WHERE \"VerificationKey\" = $1::varchar "
    values: values
  , (err, result) ->
    if err
      done? client
      console.error 'error running query', err
      callback? err
      return
    done?()
    callback?()

deleteFromDatabaseUnverifiedUserForVerificationKey = (verificationKey, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    deleteQuery [verificationKey], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      deleteQuery [verificationKey], client, done, callback
      return
  return

removeUnverifiedUser = (verificationKey, client, callback) ->
  deleteFromDatabaseUnverifiedUserForVerificationKey verificationKey, client, callback

module.exports =
  UnverifiedUser: UnverifiedUser
  type: TYPE

  addUnverifiedUser: addUnverifiedUser
  removeUnverifiedUser: removeUnverifiedUser
  getEmailForVerificationKey: getEmailForVerificationKey
  verifyVerificationKey: verifyVerificationKey
