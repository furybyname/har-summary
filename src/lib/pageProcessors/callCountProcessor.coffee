_ = require('lodash')

process = (har) ->
  entries = har['log']['entries']
  internal : _.filter(entries, (e) -> e['meta']['internal'] == true).length
  external : _.filter(entries, (e) -> e['meta']['internal'] == false).length

exports.process = process