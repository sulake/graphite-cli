expand-abbr-time = require '../src/expand-abbr-time'

describe 'expand-abbr-time' (,) ->
  it 'expands abbreviated times' ->
    eq "summarize(*, '10min', 'sum', false)",  expand-abbr-time "summarize(*, '10m', 'sum', false)"
    eq "summarize(*, '10hour', 'sum', false)", expand-abbr-time "summarize(*, '10h', 'sum', false)"
    eq "summarize(*, '10day', 'sum', false)",  expand-abbr-time "summarize(*, '10d', 'sum', false)"

  it 'expands abbreviated times in single or double quotes' ->
    eq "'10min'",  expand-abbr-time "'10m'"
    eq '"10min"',  expand-abbr-time '"10m"'

  it "doesn't expand in parens" ->
    eq '(10m)',  expand-abbr-time '(10m)'
