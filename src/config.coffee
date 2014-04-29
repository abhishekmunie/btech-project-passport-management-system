convict = require 'convict'
validator   = require 'validator'
fs      = require 'fs'
path    = require 'path'

# define a schema

existingFolder = (val) ->
  throw new Error('Source should be a directory') unless fs.statSync(path.resolve val).isDirectory()

configConvict = convict
  env:
    doc: 'The applicaton environment.'
    format: ['production', 'development', 'test']
    default: 'development'
    env: 'NODE_ENV'
    arg: 'env'
  ip:
    doc: 'The IP address to bind.'
    format: (val) -> throw new Error('must be an IP address') unless not validator? || validator.isIP val
    default: undefined
    env: 'IP_ADDRESS'
    arg: 'host'
  port:
    doc: 'The port to bind.'
    format: 'port'
    default: 1337
    env: 'PORT'
    arg: 'port'
  views_dir:
    doc: 'Directory to use to lookup views files'
    format: existingFolder
    default: 'views'
  pg_url:
    doc: 'URL of PostgreSQL database.'
    format: 'url'
    default: 'postgres://abhishekmunie@localhost/passport'
    env: 'DATABASE_URL'
  admin:
    name:
      doc: 'Name of admin user'
      format: String
      default: 'Administrator'
    email:
      doc: 'Email id of admin user'
      format: 'email'
      default: 'btech.proj.passport.management@gmail.com'
  email:
    user:
      doc: 'Email ID to use.'
      format: 'email'
      default: 'btech.proj.passport.management@gmail.com'
      env: 'EMAIL_USER'
    name:
      doc: 'Name to use in Email.'
      format: String
      default: 'Passport Management System'
      env: 'EMAIL_NAME'
    pass:
      doc: 'Email Account\'s Password.'
      format: '*'
      default: undefined
      env: 'EMAIL_PASS'
    template_dir:
      doc: 'Directory where email templates are stored.'
      format: existingFolder
      default: 'email-templates'
  trust_proxy:
    doc: 'Whether or not to trust headers set by a proxy.'
    format: Boolean
    default: false
    env: 'TRUST_PROXY'
  cookie_secret:
    doc: 'Secret to unsed for encoding and decoding cookies.'
    format: String
    default: '8nSqHn9mjxlOxexDf1pV0iNZha0y6thUYhnfkNPBRko='
    env: 'COOKIE_SECRET'
  credential_secret:
    doc: 'Secret to unsed for encoding and decoding cookies.'
    format: String
    default: '2//jgOyJcWnY3h8yZRxWZpQiRnhZJMe07NBCxGf6a4TekJtSkoRdm1WnUQrOofL7swh1ZpzLb1KEpWm8Ld9KCQ=='
    env: 'CREDENTIAL_SECRET'
  session:
    config:
      secret:
        doc: 'Secret to unsed for signed session cookie to prevent tampering.'
        format: (val) -> throw new Error() unless configConvict.get('session.type') and typeof val is 'string' and val isnt ''
        default: 'D+W9sEjBpj/Kj5nVeQnfROtVHzn9VoW24tpwPjQkn0M='
        env: 'SESSION_SECRET'
      key:
        doc: 'Session cookie name'
        format: '*'
        default: undefined
      cookie:
        secure:
          doc: 'Whether to use secure cookie.'
          format: Boolean
          default: false
        path:
          doc: 'Path for this header'
          default: undefined
        httpOnly:
          doc: 'Whether session cookie is HttpOnly, i.e. it can only be accessed by server.'
          default: true
        maxAge:
          doc: 'How long will the session persist in milliseconds'
          format: 'nat'
          default: 7 * 24 * 60 * 60 * 1000 # 1 week
      proxy:
        doc: 'trust the reverse proxy when setting secure cookies (via "x-forwarded-proto").'
        format: Boolean
        default: false
  index:
    doc: 'Filename of default page that will be served for paths ending in /'
    format: String
    default: 'index'
  static_file:
    source:
      doc: 'Directory from where static content will be served'
      format: existingFolder
      default: 'static'
    cache_size:
      doc: 'Size of static files cache in bytes.'
      format: 'nat'
      default: 300 * 1024 * 1024
  force_https:
    enable:
      doc: 'Whether to force use of secure connection'
      format: Boolean
      default: false
    host:
      doc: 'Name of default host with secure connection'
      format: '*'
      default: null
      env: 'FORCE_HTTPS_HOST'
    maxAge:
      doc: 'Max Age of "Strict-Transport-Security" header'
      format: 'nat'
      default: 0
    includeSubdomains:
      doc: 'Whether this is applicable for subdomains or not.'
      format: Boolean
      default: false

# load environment dependent configuration
env = configConvict.get 'env'
configConvict.loadFile path.resolve __dirname, "../config/#{env}.json"

module.exports = configConvict
