_ = require('lodash')

extractUniqueCookies = (entries) ->
  uniqueCookies = {}
  for entry in entries
    # This will get the last downloaded cookie value
    for cookie in entry['response']['cookies']
      name = cookie['name']
      uniqueCookies[name] = cookie
  _.map(uniqueCookies, (uc) -> uc)

sumCookieWeight = (cookiesForServer) ->
  mapped = _.map(cookiesForServer, (c) -> (c.value || '').length)
  _.reduce(mapped, (sum, length) -> sum + length)

process = (har) ->
  entries = har['log']['entries']
  groupedByServer = _.groupBy(entries, (e) -> (e['request']['url']).replace('http://', '').replace('https://', '').split('/')[0])

  result = {}
  for server, entries of groupedByServer
    uniqueCookies = extractUniqueCookies(entries)
    continue unless Object.keys(uniqueCookies).length

    result[server] =
      count       : uniqueCookies.length
      valueWeight : sumCookieWeight(uniqueCookies)
      names       : _.map(uniqueCookies, (uc) -> uc['name'])
      #details     : uniqueCookies

  reducer = (sum, r) -> sum + r['count']
  summary:
    totalCookies        : _.reduce(result, reducer, 0)
    domainsWithCookies  : _.keys(result).length
  details : result


exports.process = process