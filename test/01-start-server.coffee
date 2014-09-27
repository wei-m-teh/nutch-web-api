restify = require 'restify'
nconf = require 'nconf'
server = require '../server.coffee'


nconf.file { file : './conf/env-test.json' }
		.argv().env()

before (done) ->
	console.log 'BEFORE START SERVER'
	server.startServer()
	done()