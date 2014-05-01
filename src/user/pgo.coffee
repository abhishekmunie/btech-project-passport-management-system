crypto = require 'crypto'
user = require './user'

globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect

EntityName = '"passport"."PassportGrantingOfficer"'

TYPE = 'PassportGrantingOfficer'

class PassportGrantingOfficer extends user.User

  constructor: (@email, @name) ->
    @type = TYPE


getPassportGrantingOfficers = (callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      console.error 'error fetching client from pool', err
      callback? err
      return
    client.query
      name: "pgo_get_all"
      text: "SELECT * FROM #{EntityName} "
      values: []
    , (err, result) ->
      if err
        done? client
        console.error 'error running query', err
        callback? err
        return
      done?()
      callback? null, result.rows

insertQuery = (values, client, done, callback) ->
  client.query
    name: "pgo_insert"
    text: "INSERT INTO #{EntityName} VALUES ( $1::varchar , $2::varchar ) "
    values: values
  , (err, result) ->
    if err
      done? client
      console.error 'error running query', err
      callback? err
      return
    done?()
    callback? null, result.rows

insertPassportGrantingOfficerIntoDatabase = (email, Name, client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

  if client?
    insertQuery [email, Name], client, null, callback
  else
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      insertQuery [email, Name], client, done, callback
      return
  return

addPassportGrantingOfficer = (email, Name, client, callback) ->
  debug "Adding PGO with email: #{email}"
  tempPassword = crypto.createHash('sha1').update(crypto.randomBytes 256).digest 'hex'
  user.addUser email, tempPassword, client, (err) ->
    user.resetPasswordForUserWithEmail email, (err, res) ->
      return callback? err if err
      console.log res
      insertPassportGrantingOfficerIntoDatabase email, Name, client, callback

deleteQuery = (values, client, done, callback) ->
  client.query
    name: "pgo_delete"
    text: "DELETE FROM #{EntityName} WHERE \"email\" = $1::varchar "
    values: values
  , (err, result) ->
    if err
      done? client
      console.error 'error running query', err
      callback? err
      return
    done?()
    callback? null, result.rows

deletePassportGrantingOfficerFromDatabase = (email, client, callback) ->
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

removePassportGrantingOfficer = (email, client, callback) ->
  debug "Removing PGO with email: #{email}"
  deletePassportGrantingOfficerFromDatabase email, client, (err) ->
    user.removeUser email, client, callback


filter = (req, res, next) ->
  debug "Passport Granting Officer Auth Filter: #{req.url}"
  return res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}" unless req.session.user
  isPassportGrantingOfficer req.session.user.email, (err, pgoValidity) ->
    unless pgoValidity
      if req.session.user
        res.redirect "/auth/signin"
      else
        res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}"
    next()

module.exports =
  PassportGrantingOfficer: PassportGrantingOfficer
  type: TYPE

  filter: filter
  getPassportGrantingOfficers: getPassportGrantingOfficers
  addPassportGrantingOfficer: addPassportGrantingOfficer
  removePassportGrantingOfficer: removePassportGrantingOfficer

  isPassportGrantingOfficer: (email, callback) ->
    PGConnect (err, client, done) ->
      if err
        done? client
        console.error 'error fetching client from pool', err
        callback? err
        return
      client.query
        name: "is_passport_granting_officer"
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
        name: "get_passport_granting_officer_for_email"
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
          callback? null, new PassportGrantingOfficer(result.rows[0].email, result.rows[0].Name)
        else
          callback? null, null
