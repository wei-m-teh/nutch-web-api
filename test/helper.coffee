restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
io = require('socket.io-client')

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

getIo = () ->
	socket = io.connect urlResolver.format serverUrl, {'reconnection delay' : 0, 'reopen delay' : 0, 'force new connection' : true }
	
extendDefaultTimeout = (target) ->
	target.timeout 5000

exports.getClient = getClient
exports.getIo = getIo
exports.nutchJobStatus = 'nutchJobStatus'
exports.extendDefaultTimeout = extendDefaultTimeout

