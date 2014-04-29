crypto = require 'crypto'

globals = require './globals'
config = globals.config

encrypt = (plaintext) ->
  cipher = crypto.createCipher 'aes-256-cbc', config.credential_secret
  crypted = cipher.update plaintext, 'utf8', 'base64'
  crypted += cipher.final 'base64'
  crypted

decrypt = (crypted) ->
  decipher = crypto.createDecipher 'aes-256-cbc', config.credential_secret
  dec = decipher.update crypted, 'base64', 'utf8'
  dec += decipher.final 'utf8'
  dec

genKey = (password, salt, callback) ->
  ph = crypto.createHash('sha512').update(password).digest 'base64'
  phe = encrypt ph
  crypto.pbkdf2 phe, salt, 10000, 32, (err, key) ->
    return callback? err if err
    callback? null, new Buffer(key).toString 'hex'

module.exports =
  encrypt: encrypt
  decrypt: decrypt
  genKey: genKey