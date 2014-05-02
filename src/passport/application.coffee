
globals = require '../globals'
PGConnect = globals.PGConnect

EntityName = '"passport"."PassportApplication"'

citizen = require '../user/citizen'

class Application

  constructor: (source, data) ->
    switch source
      when 'db'
        row = data
        @Id = row.Id
        @CitizenEmail = row.CitizenEmail
        @ApplyingFor = row.ApplyingFor
        @ApplicationType = row.ApplicationType
        @PassportType = row.PassportType
        @PassportBookletType = row.PassportBookletType
        @ValidityRequired = row.ValidityRequired
        @GrantingOfficerEmail = row.GrantingOfficerEmail
        @RegionId = row.RegionId
      when 'req'
        req = data
        @CitizenEmail = req.session.user.email
        @ApplyingFor = req.param 'ApplyingFor'
        @ApplicationType = req.param 'ApplicationType'
        @PassportType = req.param 'PassportType'
        @PassportBookletType = req.param 'PassportBookletType'
        @ValidityRequired = req.param 'ValidityRequired'
        @GrantingOfficerEmail = req.param 'GrantingOfficerEmail'
        @RegionId = req.param 'RegionId'

  insertQuery: (client, done, callback) ->
    client.query
      name: "citizen_insert"
      text: "INSERT INTO #{EntityName} " +
        '("CitizenEmail" , "ApplyingFor" , "ApplicationType" , "PassportType" , "PassportBookletType" , "ValidityRequired" , "GrantingOfficerEmail" , "RegionId") ' +
        'VALUES ( $1::varchar , $2::char , $3::char , $4::char , $5::char , $6::char , $7::varchar , $8::int ) '
      values: [
        @CitizenEmail , @ApplyingFor , @ApplicationType , @PassportType , @PassportBookletType , @ValidityRequired , @GrantingOfficerEmail , @RegionId
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
        @insertQuery client, null, callback
      else
        PGConnect (err, client, done) =>
          if err
            done? client
            callback? err
            return
          @insertQuery client, done, callback

addApplication = (application, client, callback) ->
  application.insertIntoDatabase client, callback

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
      name: "get_application_for_id"
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

getApplicationsWithProfileForId = (Id, callback) ->
   PGConnect (err, client, done) ->
     if err
       done? client
       callback? err
       return
     client.query
       name: "get_application_with_profile_for_id"
       text: "SELECT * FROM #{EntityName} a , #{citizen.EntityName} c WHERE c.\"email\" = a.\"CitizenEmail\" AND a.\"Id\" = $1::int "
       values: [Id]
     , (err, result) ->
       if err
         done? client
         callback? err
         return
       done?()
       if result.rows[0]
         callback? null, result.rows[0]
       else
         callback? null, null

module.exports =
  Application: Application
  EntityName: EntityName

  attr_maps: attr_maps
  attr_list: attr_list

  expandValueUsingMap: expandValueUsingMap
  addApplication: addApplication
  getAllForEmail: getAllForEmail
  getForId: getForId
  getApplicationsWithProfileForId: getApplicationsWithProfileForId

