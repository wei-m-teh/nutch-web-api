restify = require 'restify'
http = require 'http'
mkdirp = require 'mkdirp'
nconf = require 'nconf'
winston = require 'winston'
socketio = require 'socket.io'
router = require './router.coffee'
db = require './repositories/db.coffee'
io = null
server = null

startServer = () ->
	loggerConfig()
	db.loadDb()
	server = restify.createServer { name: 'nutch-web-api' }
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