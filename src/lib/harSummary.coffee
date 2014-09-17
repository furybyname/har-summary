_ = require('lodash')

String::startsWith ?= (s) -> @slice(0, s.length) == s

isInternalUrl = (url, internalUrls) ->
  for internalUrl in internalUrls
    if url.startsWith(internalUrl)
      return true

  false

getCallCount = (entries, internalUrls) ->
  urls = _.pluck(_.map(entries, (e) -> e['request']), 'url')
  internalCount = 0
  externalCount = 0
  for url in urls
    if isInternalUrl(url, internalUrls) then internalCount++ else externalCount++

  internal : internalCount
  external : externalCount

buildHarSummary = (har, pageConfig) ->
  internalUrls = _.toArray(pageConfig['cdn']['internal'])
  internalUrls.push pageConfig['url']

  entries = har['log']['entries']

  callCount = getCallCount(entries, internalUrls)

  requestCount : callCount


exports.buildHarSummary = buildHarSummary