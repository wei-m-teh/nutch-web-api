crawler = require './crawler.coffee' 
seeds = require './seeds.coffee'
nutchStatus = require './nutchStatus.coffee'

route = (server) ->
	server.post '/crawler/inject', crawler.inject
	server.post '/crawler/generate', crawler.generate
	server.post '/crawler/fetch', crawler.fetch
	server.post '/crawler/parse', crawler.parse
	server.post '/crawler/updatedb', crawler.updateDb
	server.post '/crawler/solr-index', crawler.solrIndex
	server.post '/crawler/solr-delete-duplicates', crawler.solrDeleteDuplicates
	server.post '/seeds', seeds.create
	server.get '/seeds', seeds.getAll
	server.get '/seeds/:id', seeds.get
	server.put '/seeds/:id', seeds.update
	server.del '/seeds/:id', seeds.remove
	server.get '/nutch-status', nutchStatus.find
	server.get '/nutch-status/:id', nutchStatus.getOne

exports.route = route