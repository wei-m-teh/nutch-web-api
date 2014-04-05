crawler = require './crawler.coffee' 
seeds = require './seeds.coffee'

route = (server) ->
	server.post '/crawler/inject', crawler.inject
	server.post '/seeds', seeds.create
	server.get '/seeds', seeds.get
	server.put '/seeds/:id', seeds.update
	server.del '/seeds/:id', seeds.remove

exports.route = route