
globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect

pgo = require '../user/pgo'
va = require '../user/va'

EntityName = '"passport"."Region"'

getRegions = (callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "region_get_all"
      text: "SELECT * FROM #{EntityName} ORDER BY \"Name\" ASC "
      values: []
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, result.rows

getPGOForRegionWithId = (id, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "region_get_for_id"
      text: "SELECT \"GrantingOfficerEmail\" FROM #{EntityName} WHERE \"Id\" = $1::int "
      values: [id]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, if result.rows[0] then result.rows[0].GrantingOfficerEmail else null

getRegionIdForPGOWithEmail = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "pgo_get_regionId"
      text: "SELECT \"Id\" FROM #{EntityName} WHERE \"GrantingOfficerEmail\" = $1::varchar"
      values: [email]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, if result.rows[0] then result.rows[0].Id

rollback = (client, done) -> client.query 'ROLLBACK', (err) -> done? err

setPGOForRegionId = (Id, GrantingOfficerEmail, callback) ->
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
      pgo.addPassportGrantingOfficer GrantingOfficerEmail, "Passport Granting Officer of Region #{Id}", client, (err) ->
        if err
          rollback client, done
          callback? err
          return
        client.query
          name: "region_set_pgo"
          text: "UPDATE #{EntityName} SET \"GrantingOfficerEmail\" = $1::varchar WHERE \"Id\" = $2::int "
          values: [GrantingOfficerEmail, Id]
        , (err, result) ->
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
  return


unsetPGOForRegionId = (Id, callback) ->
  getPGOForRegionWithId Id, (err, GrantingOfficerEmail) ->
    return callback? err if err
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
        debug "Unauthorizing PGO for region id #{Id}"
        client.query
          name: "region_unset_pgo"
          text: "UPDATE #{EntityName} SET \"GrantingOfficerEmail\" = null WHERE \"Id\" = $1::int "
          values: [Id]
        , (err, result) ->
          if err
            rollback client, done
            callback? err
            return
          pgo.removePassportGrantingOfficer GrantingOfficerEmail, client, (err) ->
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
    return
  return

getValidationAuthorititesUnderPGOWithEmail = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "get_vas_under_pgo"
      text: "SELECT * FROM #{region.EntityName} , #{va.EntityName} WHERE \"GrantingOfficerEmail\" = $1::varchar AND \"RegionId\" = \"Id\" "
      values: [email]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, result.rows

module.exports =

  EntityName: EntityName

  getRegions: getRegions
  setPGOForRegionId: setPGOForRegionId
  unsetPGOForRegionId: unsetPGOForRegionId
  getRegionIdForPGOWithEmail: getRegionIdForPGOWithEmail
  getValidationAuthorititesUnderPGOWithEmail: getValidationAuthorititesUnderPGOWithEmail
