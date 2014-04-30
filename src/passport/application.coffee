
globals = require '../globals'
PGConnect = globals.PGConnect

EntityName = '"passport"."PassportApplication"'

TYPE = 'Citizen'

class Application

  constructor: (source, data) ->
    switch source
      when 'db'
        result = data
        @email = result.rows[0].email
      when 'req'
        req = data
        @email = req.param 'email'

insertQuery = (client, done, callback) ->
  client.query
    name: "citizen_insert"
    text: "INSERT INTO #{EntityName} VALUES ( " +
      '$1::varchar , '  +  # email
      " ) "
    values: [
      @email
    ]
  , (err, result) ->
    if err
      done? client
      callback? err
      return
    done?()
    callback?()

insertIntoDatabase: (client, callback) ->
  if typeof client is "function"
    callback = client
    client = undefined

    if client?
      insertQuery client, null, callback
    else
      PGConnect (err, client, done) ->
        if err
          done? client
          callback? err
          return
        insertQuery client, done, callback

addApplication = (client, callback) ->

attr_maps =
  PassportType:
    'n':'Normal'
    'd':'Diplomatic'
  ApplyingFor:
    'f':'Fresh Passport'
    'r':'Re-issue of Passport'
  ApplicationType:
    'n':'Normal'
    't':'Tatkaal'
  PassportBookletType:
    'a':'36 Pages'
    'b':'60 Pages'
  ValidityRequired:
    'a':'10 years'
    'b':'Up to age 18'
    'n':'Not Applicable'

attr_list = {}

for attr, map of attr_maps
  attr_list[attr] = []
  for key, value of map
    attr_list[attr].push
      key: key
      value: value

expandValueUsingMap = (hash) ->
  hash[attr] = map[hash[attr]] for attr, map of attr_maps
  hash

getAllForEmail = (CitizenEmail, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "get_citizen_for_email"
      text: "SELECT * FROM #{EntityName} WHERE \"CitizenEmail\" = $1::varchar"
      values: [CitizenEmail]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      if result.rows
        callback? null, (new Application('db', row) for row in result.rows)
      else
        callback? null, null

getForId = (Id, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "get_citizen_for_email"
      text: "SELECT * FROM #{EntityName} WHERE \"Id\" = $1::varchar"
      values: [Id]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      if result.rows[0]
        callback? null, new Application('db', result.rows[0])
      else
        callback? null, null

module.exports =
  Application: Application
  type: TYPE

  attr_maps: attr_maps
  attr_list: attr_list

  expandValueUsingMap:expandValueUsingMap
  addApplication: addApplication
  getAllForEmail: getAllForEmail
  getForId:getForId

