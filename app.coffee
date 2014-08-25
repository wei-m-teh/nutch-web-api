nconf = require 'nconf'
server = require './server.coffee'

environment = process.argv[2];
if !environment
	environment = 'dev'
nconf.file { file : './conf/env-' + environment + '.json' }
		.argv().env()
nconf.load()
server.startServer()