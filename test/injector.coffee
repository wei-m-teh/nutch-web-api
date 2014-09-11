restify = require 'restify'
nconf = require 'nconf'
sleep = require 'sleep'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
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
	db.get('seeds').remove {}, {multi:true} 	
	done()

afterEach () ->
			db.get('nutchStatus').remove {}, {multi:true} 	
			db.get('seeds').remove {}, {multi:true}	

describe '/crawler/inject', () ->
	describe 'POST /crawler/inject', () ->
		before () ->
			seed = {}
			seed.url = 'http://test.com'
			client.post '/seeds', seed, (err, req, res, data) ->

		it 'should submit injector job successfully, resulted in 202 status code and injector status table populated', (done) ->
			body = {}
			body.identifier = 'testInjector'
			client.post '/crawler/inject', body, (err, req, res, data) ->
				if err
					done(err)
					return
				expect(res.statusCode).to.equal(202)
				client.get '/nutch-status' + '?identifier=' + body.identifier + '&jobName=' + db.jobStatus.INJECTOR,  (err, req, res, data) ->
					if err 
						done(err)
						return
					expect(data).to.exist
					done()
		
describe '/crawler/inject', () ->
	describe 'POST /crawler/inject', () ->
		before (done) ->
			seed = {}
			seed.url = 'http://test.com'
			client.post '/seeds', seed, (err, req, res, data) ->
				done()

		it 'should NOT submit injector job successfully, when identifier is not provided to the injector, and should result in 409 status code', (done) ->
			body = {}
			client.post '/crawler/inject', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

describe '/crawler/inject', () ->
	describe 'POST /crawler/inject', () ->
		id = 'testInjector'
		before (done) ->
			seed = {}
			seed.url = 'http://test.com'
			client.post '/seeds', seed, (err, req, res, data) ->
				if err
					done(err)			
			injectorStatus = {}
			injectorStatus.status = 0
			injectorStatus.identifier = id
			injectorStatus.jobName = db.jobStatus.INJECTOR
			injectorStatus.date = Date.now()
			db.get('nutchStatus').insert injectorStatus, (err, doc) ->
				done(err)
				
		it 'should NOT submit injector job successfully, when another injector job is in progress', (done) ->
			body = {}
			body.identifier = id
			client.post '/crawler/inject', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

# TODO
# Find a way to effectively capture the status of the injector after job has been submitted. 
# Currently the tests setup and tear down steps wipes out all the seeds prior to running the each test,
# therefore causing this particular step not able to retrieve the injector status when nutch job is completed.
# describe '/crawler/inject', () ->
# 	describe 'POST /crawler/inject', () ->
# 		id = 'injector.success'
# 		before () ->
# 			seed = {}
# 			seed.url = 'http://test.com'
# 			client.post '/seeds', seed, (err, req, res, data) ->
		
# 		it 'should complete injector job successfully, and injector status updated to indicate the status to complete', (done) ->
# 			this.timeout 6000
# 			body = {}
# 			body.identifier = id
# 			client.post '/crawler/inject', body, (err, req, res, data) ->
# 				expect(res.statusCode).to.equal(202)
# 				sleep 5000, (done) -> 
# 					console.log 'I AM AWAKE'
# 					client.get '/injector-status/' + id,  (err, req, res, data) ->
# 						if err 
# 							done(err)
# 						expect(data.status).to.equal(1)
# 						done()
				
# 		after () ->
# 			db.get('injectorStatus').remove {}, {multi:true} 	
# 			db.get('seeds').remove {}, {multi:true}	

sleep = (time, callback) ->
	pass = undefined
	stop = new Date().getTime()
	while(new Date().getTime() < stop + time)
		pass
	callback()