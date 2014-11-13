restify = require 'restify'
nconf = require 'nconf'
server = require '../../server.coffee'


nconf.file { file : './conf/env-test.json' }
		.argv().env()

before (done) ->
	server.startServer()
	done()