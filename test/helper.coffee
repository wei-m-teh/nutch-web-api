restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
io = require('socket.io-client')
expect = require('chai').expect
nutchCommons = require '../routes/nutchCommons.coffee'


hostname = nconf.get 'NUTCH_WEB_API_SERVER_HOST'
port = nconf.get 'NUTCH_WEB_API_SERVER_PORT'
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

verifyJobStatus = (id, msg, jobName, expectedStatus, next) ->
	# Since Socket IO emits message to all clients, we are only 
	# interested in the message that corresponds to our test case,
	# hence the test verification is done only if the message has the
	# same id sent for the nutch process.
	if (msg.id is id and msg.name is jobName)
		expect(msg.status).to.equal(expectedStatus)			
		nutchCommons.findLatestJobStatus id, jobName, (status) ->
			expect(status).to.equal(expectedStatus)
			next()

exports.getClient = getClient
exports.getIo = getIo
exports.nutchJobStatus = 'nutchJobStatus'
exports.extendDefaultTimeout = extendDefaultTimeout
exports.verifyJobStatus = verifyJobStatus

