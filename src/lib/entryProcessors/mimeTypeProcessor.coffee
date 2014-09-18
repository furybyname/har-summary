_ = require('lodash')

mimeTypesLookup = {
  html        : ['text/html']
  text        : ['text/plain']
  javascript  : ['application/javascript', 'application/x-javascript', 'text/javascript']
  json        : ['application/json']
  image       : ['image/png', 'image/gif', 'image/jpg', 'image/jpeg']
  css         : ['text/css']
  flash       : ['application/x-shockwave-flash']
  unknown     : ['x-unknown']
}


setMimeType = (entry) ->
  rawMimeType = entry['response']['content']['mimeType']
  resourceType = 'notFoundInLookups'
  for key, mimeTypes of mimeTypesLookup
    if mimeTypes.indexOf(rawMimeType) > -1
      resourceType = key
      break

  if resourceType is 'notFoundInLookups' then console.log rawMimeType

  entry['meta']['resourceType'] = resourceType
  entry

processWeightings = (entries, filterFn) ->
  filtered = _.filter(entries, filterFn)

  grouped = _.groupBy(filtered, (f) -> f['meta']['resourceType'])

  sum = (sum, entry) -> sum + entry['response']['content']['size']

  result = {}
  for group, groupedEntries of grouped
    result[group] = _.reduce(groupedEntries, sum, 0)

  sumTotal = (sum, item) -> sum + item

  total       : _.reduce(result, sumTotal, 0)
  byResource  : result



processSubType = (entries, filterFn) ->
  filtered = _.filter(entries, filterFn)

  map = _.map(filtered, (e) -> e['meta']['resourceType'])
  reduced = _.reduce(map, (total, e) ->
    total[e] = (total[e] || 0) + 1
    total
  , {})

  reduced

prepare = (entry, pageConfig) -> setMimeType(entry)

process = (entries, pageConfig) ->

  counts :
    total    : processSubType(entries, (e) -> true)
    internal : processSubType(entries, (e) -> e['meta']['internal'] is true)
    external : processSubType(entries, (e) -> e['meta']['internal'] is false)
  weights :
    total    : processWeightings(entries, (e) -> true)
    internal : processWeightings(entries, (e) -> e['meta']['internal'] is true)
    external : processWeightings(entries, (e) -> e['meta']['internal'] is false)



exports.prepare = prepare
exports.process = process