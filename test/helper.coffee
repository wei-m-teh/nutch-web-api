restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')

hostname = nconf.get 'SERVER_HOST'
port = nconf.get 'SERVER_PORT'
serverUrl = {}
serverUrl.protocol = 'http'
serverUrl.hostname = hostname
serverUrl.port = port

# init the test client
restClientConfig = {}
restClientConfig.version = '*'
restClientConfig.url = urlResolver.format serverUrl
client = restify.createJsonClient restClientConfig

getClient = () ->
	client

exports.getClient = getClient

