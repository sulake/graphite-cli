{pipe, merge, omit, I, trim, apply, empty} = require 'ramda'

request  = require 'request'
concat   = require 'concat-stream'
debug    = require 'debug' <| 'graphite'
url      = require 'url'
VERSION  = require '../package.json' .version
chalk    = require 'chalk'
open     = require 'open'
{exit}   = process

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
      description : 'interval (e.g. "-5min")'
    * option      : \stdin
      alias       : \s
      type        : \Boolean
      description : 'read target from stdin'
      overrideRequired: true
    * option      : \output-format
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

unless argv.stdin
  run-main argv.target
else
  process.stdin.pipe concat { encoding: 'string' } (input) ->
    run-main input.trim!

function main target, from
  if argv.'print-target'
    process.stdout.write target
    exit 0

  url-obj = merge (url.parse graphite-base-url), do
    pathname: \render
    query: {
      format: argv.format or \raw
      from
      target
    }

  if argv.'image-url' or argv.'browser'
    method = (argv.'browser' and open) or console.log
    method <|
      url.format merge url-obj, do
        query: omit <[ format ]> url-obj.query

    exit 0

  (err, res, body) <- request do
    uri: url.format url-obj

  debug res.request.uri.href
  debug { res.status-code, content-length: res.headers.'content-length' }

  if err then error 'something went wrong', err

  if res.headers.'content-length' is '0'
    console.log 'empty response'
  else
    format-output = pipe do
      trim,
      argv.format is \json and format-raw-json or I

    console.log <|
      format-output body
