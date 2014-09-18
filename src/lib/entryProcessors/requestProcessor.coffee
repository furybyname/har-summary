moment = require('moment')

isInternalUrl = (url, pageConfig) ->
  internalUrls = pageConfig['allInternalUrls']
  for internalUrl in internalUrls
    if url.startsWith(internalUrl)
      return true

  false

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

prepare = (entry, pageConfig, logMeta) ->
  meta = entry['meta']
  startedAt = entry['startedDateTime'] = moment(entry['startedDateTime'])
  loadTime = logMeta['loadedDateTime']

  meta['beforePageLoad'] = !startedAt.isAfter(loadTime)
  meta['internal'] = isInternalUrl(entry['request']['url'], pageConfig)

  entry

processSubType = (entries, filterFn) -> {}

process = (entries, pageConfig, meta) -> getRequestsRelativeToPageLoad(meta, entries)


exports.prepare = prepare
exports.process = process