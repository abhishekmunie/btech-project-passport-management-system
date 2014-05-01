fs          = require 'fs'
path        = require 'path'
nodemailer  = require 'nodemailer'
hogan       = require 'hogan.js'

globals = require './globals'
config = globals.config
debug = globals.debug

smtpTransport = nodemailer.createTransport "SMTP",
    service: "Gmail"
    auth:
      user: config.email.user
      pass: config.email.pass

sendMail = (to, subject, body, callback) ->
  debug "Sending email to #{to} with subject #{subject} and body: #{body}"
  if config.env is 'production'
    smtpTransport.sendMail
        from: "#{config.email.name} <#{config.email.user}>"
        to: to
        subject: subject
        html: body
      ,(error, response) ->
        return callback? error if error
        callback? null, response
        return
  else
    process.nextTick callback

verificationMailTemplate = passwordResetTemplate = undefined

verificationMailTemplateFile = path.join config.email.template_dir, 'verification-email.html'
passwordResetTemplateFile = path.join config.email.template_dir, 'reset-email.html'

fs.readFile verificationMailTemplateFile, (err, data) ->
  return console.error err if err
  verificationMailTemplate = hogan.compile(data.toString())

fs.readFile passwordResetTemplateFile, (err, data) ->
  return console.error err if err
  passwordResetTemplate = hogan.compile(data.toString())

module.exports =
  sendVerificationEMail: (to, verificationKey, callback) ->
    sendMail to, 'Email Verification', verificationMailTemplate.render(key: encodeURIComponent(verificationKey)), callback

  sendPasswordResetEMail: (to, resetKey, callback) ->
    sendMail to, 'Password Reset', passwordResetTemplate.render(key: encodeURIComponent(resetKey)), callback
