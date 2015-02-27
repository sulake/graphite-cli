request  = require 'request'
concat   = require 'concat-stream'
debug    = require 'debug' <| 'graphite'
minimist = require 'minimist'
{pipe}   = require 'ramda'
{exit}   = process
argv     = minimist process.argv.slice(2),
  alias:
    s: \stdin
    p: \print-query
    v: \values

unless process.env.GRAPHITE_URL
  console.log 'error: set GRAPHITE_URL to env'
  exit 1

graphite-base-url = process.env.GRAPHITE_URL
  .replace // /?$ //, ''

get-values = ->
  it.split('|')[*-1]

target = argv._.0 or argv.target or do ->
  console.log <|
  """
  error: no --target given
  example: graphite --target="randomWalk(\'randomWalk\')"
  read more at http://graphite.readthedocs.org/en/latest/render_api.html#target
  """

  exit 1

from = argv.from
call = make-call _, from

unless argv.stdin
  call target
else
  process.stdin.pipe concat { encoding: 'string' } (input) ->
    call input.trim!

function make-call target, from
  if argv.'print-query'
    process.stdout.write target
    exit 0

  req-opts = 
    uri: "#graphite-base-url/render"
    qs: {
      +raw-data
      from
      target
    }

  (err, res, body) <- request req-opts

  debug res.request.uri.href
  debug req-opts.qs
  debug { res.status-code, content-length: res.headers.'content-length' }

  if err
    console.log 'something went wrong', err
    exit 1

  if res.headers.'content-length' is '0'
    console.log 'empty response'
  else
    ops = [ -> it.trim! ]
    ops := ops ++ get-values if argv.values

    (pipe ...ops) body
    |> console.log
