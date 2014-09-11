restify = require 'restify'
nconf = require 'nconf'
sleep = require 'sleep'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../repositories/db.coffee'

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

before (done) ->
	db.get('nutchStatus').remove {}, {multi:true}
	done()

afterEach (done) ->
	db.get('nutchStatus').remove {}, {multi:true} 
	done()

describe '/crawler/generate', () ->
	describe 'POST /crawler/generate successfully', () ->
		it 'should submit generator job successfully, resulted in 202 status code and generator status table populated', (done) ->
			body = {}
			body.identifier = 'testGenerator'
			client.post '/crawler/generate', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get '/nutch-status' + '?identifier=' + body.identifier + '&jobName=' + db.jobStatus.GENERATOR,  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/crawler/generate', () ->
	describe 'POST /crawler/generate without an identifier', () ->
		it 'should NOT submit generator job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/crawler/generate', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()


describe '/crawler/generate', () ->
	describe 'POST /crawler/generate while another process is in progress', () ->
		id = 'testGenerator'
		before (done) ->
			generatorStatus = {}
			generatorStatus.status = db.jobStatus.IN_PROGRESS
			generatorStatus.identifier = id
			generatorStatus.jobName = db.jobStatus.GENERATOR
			generatorStatus.date = Date.now()
			db.get('nutchStatus').insert generatorStatus, (err, doc) ->
				done(err)

		it 'should NOT submit generator job successfully, when another generator job is in progress', (done) ->
			body = {}
			body.identifier = id
			client.post '/crawler/generate', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()