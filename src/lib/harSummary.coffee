_ = require('lodash')
moment = require('moment')
yslowProcessor = require('./yslowProcessor')

String::startsWith ?= (s) -> @slice(0, s.length) == s

isInternalUrl = (url, pageConfig) ->
  internalUrls = pageConfig['allInternalUrls']
  for internalUrl in internalUrls
    if url.startsWith(internalUrl)
      return true

  false

getCallCount = (entries) ->

  ###
  {
    internal : 3
    external : 7
  }
  ###

  internal : _.filter(entries, (e) -> e['meta']['internal'] == true).length
  external : _.filter(entries, (e) -> e['meta']['internal'] == false).length

getPageLoadTime = (start, pageLoadOffset) -> moment(start.valueOf() + pageLoadOffset)

getRequestsRelativeToPageLoad = (meta, entries) ->
  ###
  {
    total : {
      before: 5,
      after: 10
    },
    internal : {
      before: 3,
      after : 4
    },
    external : {
      before: 2,
      after: 6
    }
  }
###
  loaded  = meta['loadedDateTime']
  before = 0
  after = 0
  beforeInternal = 0
  afterInternal = 0
  beforeExternal = 0
  afterExternal = 0

  for entry in entries
    meta = entry['meta']
    isAfter = entry['startedDateTime'].isAfter(loaded)
    if isAfter
      after++
      if meta['internal'] then afterInternal++ else afterExternal++
    else
      before++
      if meta['internal'] then beforeInternal++ else beforeExternal++

  {
    total : {
      before  : before
      after   : after
    },
    internal : {
      before  : beforeInternal
      after   : afterInternal
    },
    external : {
      before  : beforeExternal
      after   : afterExternal
    }
  }

prepare = (har, pageConfig) ->

  log = har['log']
  logMeta = log['meta'] = {}
  mainPage = log['pages'][0]
  startTime = logMeta['startedDateTime'] = mainPage['startedDateTime'] = moment(log['pages'][0]['startedDateTime'])
  timings = mainPage['pageTimings']
  loadTime = logMeta['loadedDateTime'] = timings['onLoad_dateTime'] = getPageLoadTime(startTime, timings['onLoad'])

  for entry in log['entries']
    startedAt = entry['startedDateTime'] = moment(entry['startedDateTime'])
    meta = {}
    meta['beforePageLoad'] = !startedAt.isAfter(loadTime)
    meta['internal'] = isInternalUrl(entry['request']['url'], pageConfig)

    entry['meta'] = meta

  har

buildHarSummary = (har, yslowData, pageConfig) ->

  internalUrls = _.toArray(pageConfig['cdn']['internal'])
  internalUrls.push pageConfig['url']
  pageConfig['allInternalUrls'] = internalUrls

  har = prepare(har, pageConfig)

  log = har['log']
  meta = log['meta']
  entries = log['entries']
  mainPage = log['pages'][0]

  callCount = getCallCount(entries)
  pageLoad = getRequestsRelativeToPageLoad(meta, entries)
  yslowSummary = yslowProcessor.buildSummary(yslowData)

  return {
    yslow     : yslowSummary
    summary   :
      requestCount        : callCount
      relativeToPageLoad  : pageLoad
  }


exports.buildHarSummary = buildHarSummary