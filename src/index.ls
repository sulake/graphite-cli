request  = require 'request'
concat   = require 'concat-stream'
debug    = require 'debug' <| 'graphite'
minimist = require 'minimist'
argv     = minimist process.argv.slice(2),
  alias:
    s: \stdin
    p: \print-query

unless process.env.GRAPHITE_URL
  console.log 'error: set GRAPHITE_URL to env'
  process.exit 1

graphite-base-url = process.env.GRAPHITE_URL
  .replace // /?$ //, ''

target = argv._.0 or argv.target or do ->
  console.log <|
  """
  error: no --target given
  example: graphite --target="randomWalk(\'randomWalk\')"
  read more at http://graphite.readthedocs.org/en/latest/render_api.html#target
  """

  process.exit 1

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
    process.exit 0

  req-opts = 
    uri: "#graphite-base-url/render"
    qs: {
      +raw-data
      from
      target
    }

  # TODO: opt -- only print values
  req = request req-opts
  req.pipe process.stdout

  debug req.uri.href
  debug req-opts.qs

  req.on \response (res) ->
    debug { res.status-code, content-length: res.headers.'content-length' }
    if res.headers.'content-length' is '0'
      console.log 'empty response'
