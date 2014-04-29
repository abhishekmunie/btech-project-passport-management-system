crypto = require 'crypto'
appCrypto = require '../crypto'

globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect
email = require '../email'

EntityName = '"passport"."User"'
TYPE = 'User'

class User

  constructor: (@email) ->
    @type = TYPE

  insertQuery = (values, client, done, callback) ->
    client.query
      name: "user_insert"
      text: "INSERT INTO #{EntityName} VALUES ( $1::varchar , $2::varchar , $3::varchar ) "
      values: values
    , (err, result) ->
      if err
        done? client
        console.error 'error running query', err
        callback? err
        return
      done?()
      callback?()

  insertIntoDatabase: (password, client, callback) ->
    if typeof client is "function"
      callback = client
      client = undefined

    crypto.randomBytes 126, (ex, buf) =>
      return callback? ex if ex
      salt = buf.toString 'base64'
      appCrypto.genKey password, salt, (err, key) =>
        return callback? err if err

        if client?
          insertQuery [@email, key, salt], client, null, callback
        else
          PGConnect (err, client, done) =>
            if err
              done? client
              console.error 'error fetching client from pool', err
              callback? err
              return
            insertQuery [@email, key, salt], client, done, callback
            return
        return
      return
    return

getSaltForEmail = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      console.error 'error fetching client from pool', err
      callback? err
      return
    client.query
      name: "user_salt"
      text: "SELECT salt FROM #{EntityName} WHERE \"email\" = $1::varchar "
      values: [email]
    , (err, result) ->
      if err
        done? client
        console.error 'error running query', err
        callback? err
        return
      done?()
      if result.rows[0]? then callback? null, result.rows[0].salt else callback?()
      return
    return
  return

verifyCredentials = (email, password, callback) ->
  getSaltForEmail email, (err, salt) ->
    return callback? err if err
    return callback? null, false unless salt
    appCrypto.genKey password, salt, (err, key) ->
      return callback? err if err
      PGConnect (err, client, done) ->
        if err
          done? client
          console.error 'error fetching client from pool', err
          callback? err
          return
        client.query
          name: "auth_signin"
          text: "SELECT count(*) AS exists FROM #{EntityName} WHERE \"email\" = $1::varchar AND \"key\" = $2::varchar "
          values: [email, key]
        , (err, result) ->
          if err
            done? client
            console.error 'error running query', err
            callback? err
            return
          done?()
          callback? null, result.rows[0].exists is '1'

addUser = (email, password, client, callback) ->
  debug "Adding user with email: #{email}"
  new User(email).insertIntoDatabase password, client, callback



deleteQuery = (values, client, done, callback) ->
  client.query
    name: "user_delete"
    text: "DELETE FROM #{EntityName} WHERE \"email\" = $1::varchar "
    values: values
  , (err, result) ->
    if err
      done? client
      console.error 'error running query', err
      callback? err
      return
    done?()
    callback?()

deleteFromDatabaseUserForEmail = (email, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    deleteQuery [email], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      deleteQuery [email], client, done, callback
      return
  return

removeUser = (email, client, callback) ->
  debug "Removing User with email: #{email}"
  deleteFromDatabaseUserForEmail email, client, callback

resetPasswordForUserWithEmail = (email, callback) ->
  debug "Resetting password for email: #{email}"
  # email.sendPasswordResetEMail
  process.nextTick callback

module.exports =
  User: User
  type: TYPE

  addUser: addUser
  removeUser: removeUser
  getSaltForEmail: getSaltForEmail
  verifyCredentials: verifyCredentials
  resetPasswordForUserWithEmail: resetPasswordForUserWithEmail
