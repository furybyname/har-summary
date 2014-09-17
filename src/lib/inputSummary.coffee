getPageConfig = (pages = [], id) ->
  for page in pages
    if page['id'] == id
      return page

  return {}

buildInputSummary = (config, har) ->
  log = har['log']
  id = log['pages'][0]['id']
  pageConfig = getPageConfig(config['pages'], id)

  {
    'page' : pageConfig['friendlyName'] || id
  }

exports.buildInputSummary = buildInputSummary
