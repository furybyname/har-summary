stripTrailingSlash = (str) -> if(str.substr(-1) == '/') then return str.substr(0, str.length - 1) else return str

getPageConfig = (pages = [], id) ->
  for page in pages
    if stripTrailingSlash(page['id']) == id
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
  id = stripTrailingSlash(log['entries'][0]['request']['url'].trim('/'))

  console.log id
  pageConfig = getPageConfig(config['pages'], id)

  {
    'url'   : id
    'name'  : pageConfig['friendlyName'] || id
    'cdn'   : getCdns(pageConfig, id)
  }

exports.buildInputSummary = buildInputSummary
