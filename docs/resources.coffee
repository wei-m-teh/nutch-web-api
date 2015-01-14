swagger = require 'swagger-node-restify'

# find Seed by id resource
findSeedById = {}
findSeedByIdSpec = {}
findSeedByIdSpec.description = "Operations about retrieving Seeds"
findSeedByIdSpec.path = "/seeds/{seedId}"
findSeedByIdSpec.notes = "Returns a seed resource based on the seedId"
findSeedByIdSpec.summary = "Find seed by id"
findSeedByIdSpec.method = "GET"
findSeedByIdSpec.type = "Seed"
findSeedByIdSpec.parameters = [ swagger.params.path("seedId", "ID of seed that needs to be fetched", "string") ]
findSeedByIdSpec.nickname = "findSeedById"
findSeedById.spec = findSeedByIdSpec


# find all Seeds resource
findAllSeeds = {}
findAllSeedsSpec = {}
findAllSeedsSpec.description = "Operations about retrieving Seeds"
findAllSeedsSpec.path = "/seeds"
findAllSeedsSpec.notes = "Returns all seed resources"
findAllSeedsSpec.summary = "Find all seeds"
findAllSeedsSpec.method = "GET"
findAllSeedsSpec.type = "Seed"
findAllSeedsSpec.nickname = "findAll"
findAllSeeds.spec = findAllSeedsSpec


# create new Seed resource
createSeed = {}
createSeedSpec = {}
createSeedSpec.description = "Operations about creating Seed"
createSeedSpec.path = "/seeds"
createSeedSpec.notes = "Creates a new Seed resources"
createSeedSpec.summary = "Creates a new Seed resource"
createSeedSpec.method = "POST"
createSeedSpec.type = "Seed"
createSeedSpec.nickname = "create"
createSeed.spec = createSeedSpec


# Update an existing Seed resource
updateSeed = {}
updateSeedSpec = {}
updateSeedSpec.description = "Operations about updating existing Seeds"
updateSeedSpec.path = "/seeds/{seedId}"
updateSeedSpec.notes = "Updates an existing Seed resource"
updateSeedSpec.summary = "Updates an existing Seed for the given id"
updateSeedSpec.method = "PUY"
updateSeedSpec.type = "Seed"
updateSeedSpec.parameters = [ swagger.params.path("seedId", "ID of seed that needs to be updated", "string") ]
updateSeedSpec.nickname = "update"
updateSeed.spec = updateSeedSpec


# Crawl resource
crawl = {}
crawlSpec = {}
crawlSpec.description = "Operations about POSTing a crawl job"
crawlSpec.path = "/crawl"
crawlSpec.notes = "Submits a new Nutch crawl job"
crawlSpec.summary = "Submits a new Nutch crawl job"
crawlSpec.method = "POST"
crawlSpec.type = "Crawler"
crawlSpec.nickname = "crawl"
crawl.spec = crawlSpec

# Inject resource
inject = {}
injectSpec = {}
injectSpec.description = "Operations about POSTing an injector job"
injectSpec.path = "/inject"
injectSpec.notes = "Submits a new Nutch injector job"
injectSpec.summary = "Submits a new Nutch injector job"
injectSpec.method = "POST"
injectSpec.type = "Injector"
injectSpec.nickname = "inject"
inject.spec = injectSpec

# Generate resource
generate = {}
generateSpec = {}
generateSpec.description = "Operations about POSTing a generator job"
generateSpec.path = "/generate"
generateSpec.notes = "Submits a new Nutch generator job"
generateSpec.summary = "Submits a new Nutch generator job"
generateSpec.method = "POST"
generateSpec.type = "Generator"
generateSpec.nickname = "generate"
generate.spec = generateSpec

# Fetch resource
fetch = {}
fetchSpec = {}
fetchSpec.description = "Operations about POSTing a fetcher job"
fetchSpec.path = "/fetch"
fetchSpec.notes = "Submits a new Nutch fetcher job"
fetchSpec.summary = "Submits a new Nutch fetcher job"
fetchSpec.method = "POST"
fetchSpec.type = "Fetcher"
fetchSpec.nickname = "fetch"
fetch.spec = fetchSpec

# Parse resource
parse = {}
parseSpec = {}
parseSpec.description = "Operations about POSTing a parser job"
parseSpec.path = "/parse"
parseSpec.notes = "Submits a new Nutch parser job"
parseSpec.summary = "Submits a new Nutch parser job"
parseSpec.method = "POST"
parseSpec.type = "Parser"
parseSpec.nickname = "parse"
parse.spec = parseSpec

# UpdateDb resource
updateDb = {}
updateDbSpec = {}
updateDbSpec.description = "Operations about POSTing a updateDb job"
updateDbSpec.path = "/updateDb"
updateDbSpec.notes = "Submits a new Nutch updateDb job"
updateDbSpec.summary = "Submits a new Nutch updateDb job"
updateDbSpec.method = "POST"
updateDbSpec.type = "DbUpdater"
updateDbSpec.nickname = "updatedb"
updateDb.spec = updateDbSpec

# SolrIndex resource
solrindex = {}
solrindexSpec = {}
solrindexSpec.description = "Operations about POSTing a solrIndexer job"
solrindexSpec.path = "/solr-index"
solrindexSpec.notes = "Submits a new Nutch solrIndexer job"
solrindexSpec.summary = "Submits a new Nutch solrIndexer job"
solrindexSpec.method = "POST"
solrindexSpec.type = "SolrIndexer"
solrindexSpec.nickname = "solr-index"
solrindex.spec = solrindexSpec

# SolrDeleteDuplicates resource
solrdeleteduplicates = {}
solrdeleteduplicatesSpec = {}
solrdeleteduplicatesSpec.description = "Operations about POSTing a Solr delete duplicates job"
solrdeleteduplicatesSpec.path = "/solr-delete-duplicates"
solrdeleteduplicatesSpec.notes = "Submits a new Nutch Solr delete duplicates job"
solrdeleteduplicatesSpec.summary = "Submits a new Nutch Solr delete duplicates job"
solrdeleteduplicatesSpec.method = "POST"
solrdeleteduplicatesSpec.type = "SolrDeleteDuplicates"
solrdeleteduplicatesSpec.nickname = "solr-delete-duplicates"
solrdeleteduplicates.spec = solrdeleteduplicatesSpec

exports.findSeedById = findSeedById
exports.findAllSeeds = findAllSeeds
exports.createSeed = createSeed
exports.updateSeed = updateSeed
exports.crawl = crawl
exports.inject = inject
exports.generate = generate
exports.fetch = fetch
exports.parse = parse
exports.updateDb = updateDb
exports.solrindex = solrindex
exports.solrdeleteduplicates = solrdeleteduplicates


