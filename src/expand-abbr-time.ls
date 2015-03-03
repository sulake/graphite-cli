module.exports = (str) ->
  str.replace /\b(\d+)([mhd])\b/, (mat, digit, abbr) ->
    "#digit" + switch abbr
      | \m => \min
      | \h => \hour
      | \d => \day
