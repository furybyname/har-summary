stripTrailingSlash = (str) -> if(str.substr(-1) == '/') then return str.substr(0, str.length - 1) else return str

getPageConfig = (pages = [], id) ->
  for page in pages
    if stripTrailingSlash(page['id']) == id
      return page

  return {}

extendCdns = (globalCdns, localCdns) ->
  for cdn in globalCdns
    localCdns.push(cdn) unless localCdns.indexOf(cdn) > -1

  localCdns

getCdns = (config, pageConfig, id) ->
  cdn = pageConfig['cdn'] || {}
  internal = cdn['internal'] || []
  external = cdn['external'] || []

  globalCdn = config['cdn'] or {}
  globalInternalCdn = globalCdn['internal'] or []
  globalExternalCdn = globalCdn['external'] or []

  internal = extendCdns(globalInternalCdn, internal)
  external = extendCdns(globalExternalCdn, external)

  internal : internal
  external : external

buildInputSummary = (config, har) ->
  log = har['log']
  id = stripTrailingSlash(log['entries'][0]['request']['url'].trim('/'))

  pageConfig = getPageConfig(config['pages'], id)

  {
    'url'   : id
    'name'  : pageConfig['friendlyName'] || id
    'cdn'   : getCdns(config, pageConfig, id)
  }

exports.buildInputSummary = buildInputSummary
