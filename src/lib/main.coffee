buildInputSummary = require('./inputSummary').buildInputSummary

run = (har, config) ->
  throw 'HAR must be object' unless typeof har == 'object'

  buildInputSummary(config, har)

exports.run = run
