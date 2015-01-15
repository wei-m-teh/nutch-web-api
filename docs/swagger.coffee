swagger = require 'swagger-node-restify'
nconf = require 'nconf'
models = require './models.coffee'
resources = require './resources.coffee'

create = (server) ->
	serverUrl = nconf.get('NUTCH_WEB_API_SERVER_HOST')
	serverPort = nconf.get('NUTCH_WEB_API_SERVER_PORT')

	swagger.setAppHandler server
	swagger.addModels models 
	swagger.addGet resources.findAllSeeds
	swagger.addGet resources.findSeedById
	swagger.addPost resources.createSeed
	swagger.addPut resources.updateSeed
	swagger.addPost resources.crawl
	swagger.addPost resources.inject
	swagger.addPost resources.generate
	swagger.addPost resources.fetch
	swagger.addPost resources.parse
	swagger.addPost resources.updateDb
	swagger.addPost resources.solrindex
	swagger.addPost resources.solrdeleteduplicates
	swagger.configureSwaggerPaths "", "api-docs", ""
	swagger.configure "http://#{serverUrl}:#{serverPort}/nutch", "1.0.0"
	return

exports.create = create