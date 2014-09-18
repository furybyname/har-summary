_ = require('lodash')
moment = require('moment')
yslowProcessor = require('./yslowProcessor')
mimeTypeProcessor = require('./entryProcessors/mimeTypeProcessor')
requestProcessor = require('./entryProcessors/requestProcessor')
metaProcessor = require('./metaProcessor')
callCountProcessor = require('./callCountProcessor')

String::startsWith ?= (s) -> @slice(0, s.length) == s

prepare = (har, pageConfig) ->

  har = metaProcessor.process(har)
  log = har['log']
  logMeta = log['meta']

  for entry in log['entries']
    entry['meta'] = meta = {}

    entry = requestProcessor.prepare(entry, pageConfig, logMeta)
    entry = mimeTypeProcessor.prepare(entry, pageConfig)

  har

buildHarSummary = (har, yslowData, pageConfig) ->

  internalUrls = _.toArray(pageConfig['cdn']['internal'])
  internalUrls.push pageConfig['url']
  pageConfig['allInternalUrls'] = internalUrls

  har = prepare(har, pageConfig)

  log     = har['log']
  meta    = log['meta']
  entries = log['entries']


  ySlow     : yslowProcessor.process(yslowData)
  summary   :
    requestCount        : callCountProcessor.process(entries)
    relativeToPageLoad  : requestProcessor.process(entries, pageConfig, meta)
    resources           : mimeTypeProcessor.process(entries, pageConfig)


exports.buildHarSummary = buildHarSummary