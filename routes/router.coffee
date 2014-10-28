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
	server.get '/nutch/status/:id', nutchStatus.getOne

exports.route = route