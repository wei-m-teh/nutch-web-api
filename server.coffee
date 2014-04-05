restify = require 'restify'
http = require 'http'
mkdirp = require 'mkdirp'
nconf = require 'nconf'
winston = require 'winston'
router = require './routes/router.coffee'

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

nconf.file { file : './conf/env-dev.json' }
	.argv().env()
       
nconf.load()

server = restify.createServer { name: 'nutch-web-api' }
server.use restify.bodyParser()
server.use restify.queryParser()

router.route server

server.listen process.env.PORT || 3000, process.env.IP | "0.0.0.0", () ->
  console.log '%s listening at %s', server.name, server.url