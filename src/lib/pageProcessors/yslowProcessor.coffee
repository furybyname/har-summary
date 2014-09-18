getStats = (stats, key) ->
  requests  : stats[key]['r']
  weight    : stats[key]['w']

processHAR = (data) ->

  YSlow = require('yslow').YSLOW
  doc = require('jsdom').jsdom()
  res = YSlow.harImporter.run(doc, data, 'ydefault')
  content = YSlow.util.getResults(res.context, 'all')

  return content


process = (har) ->
  ySlow = processHAR(har)

  s = ySlow['stats']
  stats   : {
    totalWeight                       : ySlow['w']
    totalRequests_excludingRedirects  : ySlow['r']
    documents                         : getStats(s, 'doc')
    css                               : getStats(s, 'css')
    javascript                        : getStats(s, 'js')
    images                            : getStats(s, 'image')
    cssImages                         : getStats(s, 'cssimage')
    json                              : getStats(s, 'json')
    flash                             : getStats(s, 'flash')
    redirects                         : getStats(s, 'redirect')
  }

exports.processHAR = processHAR
exports.process = process