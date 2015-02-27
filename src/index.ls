{pipe, merge, omit, I, trim} = require 'ramda'

request  = require 'request'
concat   = require 'concat-stream'
debug    = require 'debug' <| 'graphite'
minimist = require 'minimist'
{exit}   = process
url      = require 'url'

argv = minimist process.argv.slice(2),
  alias:
    s: \stdin
    p: \print-query
    i: \image-url
    f: \format

stringify       = JSON.stringify _, void, 4
format-raw-json = stringify . JSON.parse

die = (msg) ->
  console.error msg
  exit 1

unless process.env.GRAPHITE_URL
  die 'error: set GRAPHITE_URL to env'

graphite-base-url = process.env.GRAPHITE_URL
  .replace // /?$ //, ''

target = argv._.0 or argv.target or do ->
  die <|
  '''
  error: no --target given
  example: graphite --target="randomWalk(\'randomWalk\')"
  read more at http://graphite.readthedocs.org/en/latest/render_api.html#target
  '''

from = argv.from
run-main = main _, from

unless argv.stdin
  run-main target
else
  process.stdin.pipe concat { encoding: 'string' } (input) ->
    run-main input.trim!

function main target, from
  if argv.'print-query'
    process.stdout.write target
    exit 0

  url-obj = merge (url.parse graphite-base-url), do
    pathname: \render
    query: {
      format: argv.format or \raw
      from
      target
    }

  if argv.'image-url'
    console.log <|
      url.format merge url-obj, do
        query: omit <[ format ]> url-obj.query

    exit 0

  (err, res, body) <- request do
    uri: url.format url-obj

  debug res.request.uri.href
  debug { res.status-code, content-length: res.headers.'content-length' }

  if err then die 'something went wrong', err

  if res.headers.'content-length' is '0'
    console.log 'empty response'
  else
    format-output = pipe do
      trim,
      argv.format is \json and format-raw-json or I

    console.log <|
      format-output body
