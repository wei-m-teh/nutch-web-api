restify = require 'restify'
http = require 'http'
mkdirp = require 'mkdirp'
nconf = require 'nconf'
winston = require 'winston'
socketio = require 'socket.io'
swagger = require 'swagger-node-restify'
router = require './router.coffee'
db = require './repositories/db.coffee'
models = require './docs/models.coffee'
resources = require './docs/resources.coffee'
io = null
server = null

startServer = () ->
	loggerConfig()
	db.loadDb()
	server = restify.createServer { name: 'nutch-web-api' }
	serverUrl = nconf.get('NUTCH_WEB_API_SERVER_HOST')
	serverPort = nconf.get('NUTCH_WEB_API_SERVER_PORT')


	# Configure swaggger API documentation	
	restify.defaultResponseHeaders = (data) ->
		this.header 'Access-Control-Allow-Origin', '*' 

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

	io = socketio.listen server
	server.use restify.bodyParser()
	server.use restify.queryParser()
	router.route server		
	server.listen nconf.get('NUTCH_WEB_API_SERVER_PORT'), nconf.get('NUTCH_WEB_API_SERVER_HOST'), () ->
  	console.log '%s listening at %s', server.name, server.url
		
getIo = () ->
	io

loggerConfig = () ->
	# Create log directory if it does not already exists.
	mkdirp process.cwd() + "/logs", (err) ->
  	if err? 
	  	throw err

	# Setting up logging framework with winston
	loggerOpt = {}
	loggerOpt.filename = process.cwd() + '/logs/node.log'
	loggerOpt.maxsize = 100000
	winston.add winston.transports.File, loggerOpt
	winston.remove winston.transports.Console

exports.startServer = startServer
exports.getIo = getIo