getPageConfig = (pages = [], id) ->
  for page in pages
    if page['id'] == id
      return page

  return {}

getCdns = (pageConfig, id) ->
  cdn = pageConfig['cdn'] || {}
  internal = cdn['internal'] || []
  external = cdn['external'] || []

  internal : internal
  external : external

buildInputSummary = (config, har) ->
  log = har['log']
  id = log['pages'][0]['id']
  pageConfig = getPageConfig(config['pages'], id)

  {
    'url'   : id
    'name'  : pageConfig['friendlyName'] || id
    'cdn'   : getCdns(pageConfig, id)
  }

exports.buildInputSummary = buildInputSummary
