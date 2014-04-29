
user  = require './user'
admin = require './admin'

module.exports =
  verifyCredentials: (email, password, callback) ->
    user.verifyCredentials email, password, (err, validity) ->
      return callback? err if err
      if validity is true
        return callback? null, true
      else
        admin.verifyCredentials email, password, (err, validity) ->
          return callback? err if err
          callback? null, validity
          return
      return
    return