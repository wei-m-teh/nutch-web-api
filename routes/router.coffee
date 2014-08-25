crawler = require './crawler.coffee' 
seeds = require './seeds.coffee'
injectorStatus = require './injectorStatus.coffee'

route = (server) ->
	server.post '/crawler/inject', crawler.inject
	server.post '/seeds', seeds.create
	server.get '/seeds', seeds.getAll
	server.get '/seeds/:id', seeds.get
	server.put '/seeds/:id', seeds.update
	server.del '/seeds/:id', seeds.remove
	server.get '/injector-status', injectorStatus.getAll 
	server.get '/injector-status/:id', injectorStatus.get 

exports.route = route