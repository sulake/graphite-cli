expand-abbr-time = require '../src/expand-abbr-time'

describe 'expand-abbr-time' (,) ->
  it 'should expand abbreviated times' ->
    eq "summarize(*, '10min', 'sum', false)",  expand-abbr-time "summarize(*, '10m', 'sum', false)"
    eq "summarize(*, '10hour', 'sum', false)", expand-abbr-time "summarize(*, '10h', 'sum', false)"
    eq "summarize(*, '10day', 'sum', false)",  expand-abbr-time "summarize(*, '10d', 'sum', false)"
