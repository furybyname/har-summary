moment = require('moment')

getPageLoadTime = (start, pageLoadOffset) -> moment(start.valueOf() + pageLoadOffset)

process = (har) ->
  log = har['log']
  logMeta = log['meta'] = {}
  mainPage = log['pages'][0]
  startTime = logMeta['startedDateTime'] = mainPage['startedDateTime'] = moment(log['pages'][0]['startedDateTime'])
  timings = mainPage['pageTimings']
  logMeta['loadedDateTime'] = timings['onLoad_dateTime'] = getPageLoadTime(startTime, timings['onLoad'])

  har

exports.process = process