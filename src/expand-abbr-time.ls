module.exports = (str) ->
  str.replace /(['"])(\d+)([mhd])(['"])/, (mat, open, digit, abbr, close) ->
    unit = switch abbr
    | \m => \min
    | \h => \hour
    | \d => \day

    [ open, digit, unit, close ] * ''
