crawler = require './libs/crawler.coffee'
injector = require './libs/injector.coffee' 
generator = require './libs/generator.coffee'
fetcher = require './libs/fetcher.coffee'
parser = require './libs/parser.coffee'
dbUpdater = require './libs/dbUpdater.coffee'
solrIndexer = require './libs/solrIndexer.coffee'
seeds = require './libs/seeds.coffee'
nutchStatus = require './libs/nutchStatus.coffee'

route = (server) ->
	server.post '/nutch/crawl', crawler.crawl
	server.post '/nutch/inject', injector.inject
	server.post '/nutch/generate', generator.generate
	server.post '/nutch/fetch', fetcher.fetch
	server.post '/nutch/parse', parser.parse
	server.post '/nutch/updatedb', dbUpdater.update
	server.post '/nutch/solr-index', solrIndexer.index
	server.post '/nutch/solr-delete-duplicates', solrIndexer.deleteDuplicates
	server.post '/nutch/seeds', seeds.create
	server.get '/nutch/seeds', seeds.getAll
	server.get '/nutch/seeds/:id', seeds.get
	server.put '/nutch/seeds/:id', seeds.update
	server.del '/nutch/seeds/:id', seeds.remove
	server.get '/nutch/status', nutchStatus.find

exports.route = route