crawler = require './crawler.coffee'
injector = require './injector.coffee' 
generator = require './generator.coffee'
fetcher = require './fetcher.coffee'
parser = require './parser.coffee'
dbUpdater = require './dbUpdater.coffee'
solrIndexer = require './solrIndexer.coffee'
seeds = require './seeds.coffee'
nutchStatus = require './nutchStatus.coffee'

route = (server) ->
	server.post '/crawler/crawl', crawler.crawl
	server.post '/crawler/inject', injector.inject
	server.post '/crawler/generate', generator.generate
	server.post '/crawler/fetch', fetcher.fetch
	server.post '/crawler/parse', parser.parse
	server.post '/crawler/updatedb', dbUpdater.update
	server.post '/crawler/solr-index', solrIndexer.index
	server.post '/crawler/solr-delete-duplicates', solrIndexer.deleteDuplicates
	server.post '/seeds', seeds.create
	server.get '/seeds', seeds.getAll
	server.get '/seeds/:id', seeds.get
	server.put '/seeds/:id', seeds.update
	server.del '/seeds/:id', seeds.remove
	server.get '/nutch-status', nutchStatus.find
	server.get '/nutch-status/:id', nutchStatus.getOne

exports.route = route