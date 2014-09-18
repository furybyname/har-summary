buildInputSummary = require('./inputSummary').buildInputSummary
buildHarSummary = require('./harSummary').buildHarSummary
yslowProcessor = require('./yslowProcessor')

run = (har, config) ->
  throw 'HAR must be object' unless typeof har == 'object'

  pageConfig = buildInputSummary(config, har)
  buildHarSummary(har, pageConfig)

exports.run = run
