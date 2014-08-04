crawler = require './crawler.coffee' 
seeds = require './seeds.coffee'
injectorStatus = require './injectorStatus.coffee'
db = require '../repositories/db.coffee'

route = (server) ->
	server.post '/crawler/inject', crawler.inject
	server.post '/seeds', seeds.create
	server.get '/seeds', seeds.get
	server.put '/seeds/:id', seeds.update
	server.del '/seeds/:id', seeds.remove
	server.get '/injector-status', injectorStatus.get 

exports.route = route