{pipe, merge, omit, I, trim, apply, empty, head} = require 'ramda'

request          = require 'request'
debug            = require 'debug' <| 'graphite'
url              = require 'url'
VERSION          = require '../package.json' .version
{red}            = require 'chalk'
open             = require 'open'
fs               = require 'fs'
expand-abbr-time = require './expand-abbr-time'
{exit}           = process

die = ->
  apply console.error, arguments
  exit 1

fmt-error       = -> (red.bold 'ERROR: ') + red it
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
      description : 'interval'
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
      description : 'print graph image URL'
    * option      : \browser
      alias       : \b
      type        : \Boolean
      description : 'open as image in browser'
    * option      : \curl
      alias       : \c
      type        : \Boolean
      description : 'send graph image data to stdout'
    * option      : \help
      alias       : \h
      type        : \Boolean
      description : 'displays help'

try
  unless process.env.GRAPHITE_URL
    throw new Error fmt-error 'set GRAPHITE_URL to env'

  argv = optionator.parse process.argv
catch
  die [optionator.generate-help!, e.message] * "\n\n"

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

  params = { from, target }
  url-obj = merge (url.parse graphite-base-url),
    pathname: \render

  curl = ->
    request it .pipe process.stdout

  if argv.image-url or argv.browser or argv.curl
    action = switch
    | argv.browser   => open
    | argv.curl      => curl
    | argv.image-url => console~log
    action url.format merge url-obj, query: params
    return

  (err, res, body) <- request.post do
    uri: url.format url-obj
    form: merge params,
      format: argv.format or \raw

  if err then die fmt-error err.message

  debug do
    uri:            res.request.uri.href
    data:           res.request.body.to-string!
    status-code:    res.status-code
    content-length: res.headers.'content-length'

  if res.headers.'content-length' is '0'
    console.log 'empty response'
  else
    format-output = pipe do
      trim,
      argv.format is \json and format-raw-json or I

    console.log <|
      format-output body
