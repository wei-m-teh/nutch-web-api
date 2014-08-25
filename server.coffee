restify = require 'restify'
http = require 'http'
mkdirp = require 'mkdirp'
nconf = require 'nconf'
winston = require 'winston'
router = require './routes/router.coffee'
db = require './repositories/db.coffee'

startServer = () ->
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
	db.loadDb()
	server = restify.createServer { name: 'nutch-web-api' }
	server.use restify.bodyParser()
	server.use restify.queryParser()

	router.route server

	server.listen nconf.get('SERVER_PORT'), nconf.get('SERVER_HOST'), () ->
	  console.log '%s listening at %s', server.name, server.url

exports.startServer = startServer