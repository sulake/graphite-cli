{pipe, merge, omit, I, trim, apply, empty, head} = require 'ramda'

request          = require 'request'
concat           = require 'concat-stream'
debug            = require 'debug' <| 'graphite'
url              = require 'url'
VERSION          = require '../package.json' .version
chalk            = require 'chalk'
open             = require 'open'
fs               = require 'fs'
expand-abbr-time = require './expand-abbr-time'
{exit}           = process

error = ->
  apply console.error, arguments
  exit 1

stringify       = JSON.stringify _, void, 4
format-raw-json = stringify . JSON.parse

optionator = require 'optionator' <| do
  prepend: 'Usage: graphite [options]'
  append: "Version #VERSION"
  options:
    * option      : \target
      alias       : \t
      type        : \String
      description : 'target'
      required    : true
    * option      : \from
      alias       : \f
      type        : \String
      description : 'interval (default: -1day)'
      default     : \-1day
    * option      : \stdin
      alias       : \s
      type        : \Boolean
      description : 'read target from stdin'
      overrideRequired: true
    * option      : \format
      alias       : \o
      type        : \String
      description : 'output format (json, csv, raw)'
    * option      : \print-target
      alias       : \p
      type        : \Boolean
      description : 'print target'
    * option      : \image-url
      alias       : \i
      type        : \Boolean
      description : 'print image graph URL'
    * option      : \browser
      alias       : \b
      type        : \Boolean
      description : 'open as image in browser'
    * option      : \help
      alias       : \h
      type        : \Boolean
      description : 'displays help'

try
  unless process.env.GRAPHITE_URL
    throw new Error chalk.red.bold 'Error: set GRAPHITE_URL to env'

  argv = optionator.parse process.argv
catch
  error [optionator.generate-help!, chalk.bold e.message] * "\n\n"

graphite-base-url = process.env.GRAPHITE_URL
  .replace // /?$ //, ''

from = argv.from
run-main = main _, from

target = argv.target or do
  size = fs.fstat-sync process.stdin.fd .size
  trim head fs.read-sync process.stdin.fd, size
|> expand-abbr-time

main target, from

function main target, from
  if argv.print-target
    process.stdout.write target
    exit 0

  params = {
    from
    target
  }

  url-obj = merge (url.parse graphite-base-url),
    pathname: \render

  if argv.image-url or argv.browser
    action = (argv.browser and open) or console.log
    action url.format merge url-obj, query: params
    exit 0

  (err, res, body) <- request.post do
    uri: url.format url-obj
    form: merge params,
      format: argv.format or \raw

  debug {
    uri  : res.request.uri.href
    data : res.request.body.to-string!
  }

  debug {
    res.status-code,
    content-length: res.headers.'content-length'
  }

  if err then error 'something went wrong', err

  if res.headers.'content-length' is '0'
    console.log 'empty response'
  else
    format-output = pipe do
      trim,
      argv.format is \json and format-raw-json or I

    console.log <|
      format-output body
