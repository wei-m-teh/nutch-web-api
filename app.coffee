domain = require('domain').create()
nconf = require 'nconf'
server = require './server.coffee'

environment = process.argv[2];
if !environment
	environment = 'dev'
nconf.file { file : './conf/env-' + environment + '.json' }
		.argv().env()
nconf.load()

domain.on 'error', (err) ->
	console.log err.message

domain.run () ->
	server.startServer()