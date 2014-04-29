
globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect

pgo = require '../user/pgo'

EntityName = '"passport"."Region"'

getRegions = (callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      console.error 'error fetching client from pool', err
      callback? err
      return
    client.query
      name: "region_get_all"
      text: "SELECT * FROM #{EntityName} ORDER BY \"Name\" ASC "
      values: []
    , (err, result) ->
      if err
        done? client
        console.error 'error running query', err
        callback? err
        return
      done?()
      callback? null, result.rows

getPGOForRegionWithId = (id, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      console.error 'error fetching client from pool', err
      callback? err
      return
    client.query
      name: "region_get_for_id"
      text: "SELECT \"GrantingOfficerEmail\" FROM #{EntityName} WHERE \"Id\" = $1::int "
      values: [id]
    , (err, result) ->
      if err
        done? client
        console.error 'error running query', err
        callback? err
        return
      done?()
      callback? null, if result.rows[0] then result.rows[0].GrantingOfficerEmail else null

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
            done?()
            callback? null, result.rows


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
              done?()
            callback? null, result.rows

module.exports =
  getRegions: getRegions
  setPGOForRegionId: setPGOForRegionId
  unsetPGOForRegionId: unsetPGOForRegionId
