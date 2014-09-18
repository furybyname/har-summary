_ = require('lodash')

process = (entries) ->
  internal : _.filter(entries, (e) -> e['meta']['internal'] == true).length
  external : _.filter(entries, (e) -> e['meta']['internal'] == false).length

exports.process = process