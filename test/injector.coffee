restify = require 'restify'
nconf = require 'nconf'
sleep = require 'sleep'
io = require('socket.io-client')
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
nutchCommons = require '../routes/nutchCommons.coffee'

client = helper.getClient()
 
before () ->
	db.get('nutchStatus').remove {}, {multi:true} 	
	db.get('seeds').remove {}, {multi:true} 	

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
					return			
			injectorStatus = {}
			injectorStatus.status = 0
			injectorStatus.identifier = id
			injectorStatus.jobName = db.jobStatus.INJECTOR
			injectorStatus.date = Date.now()
			db.get('nutchStatus').insert injectorStatus, (err, doc) ->
				done(err)
				return
				
		it 'should NOT submit injector job successfully, when another injector job is in progress', (done) ->
			body = {}
			body.identifier = id
			client.post '/crawler/inject', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

describe 'POST /crawler/inject', () ->
	helper.extendDefaultTimeout this
	id = 'injector.success'
	socket =
	before () ->
		socket = helper.getIo()
		seed = {}
		seed.url = 'http://test.com'
		client.post '/seeds', seed, (err, req, res, data) ->
	
	it 'should complete injector job successfully, and injector status updated to indicate the status to complete', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			# Since Socket IO emits message to all clients, we are only 
			# interested in the message that corresponds to our test case,
			# hence the test verification is done only if the message has the
			# same id sent for the nutch process.
			if (msg.id is id)
				expect(msg.status).to.equal(db.jobStatus.SUCCESS)
				nutchCommons.findLatestJobStatus id, db.jobStatus.INJECTOR, (status) ->
					expect(status).to.equal(db.jobStatus.SUCCESS)
					done()

		client.post '/crawler/inject', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

describe 'POST /crawler/inject', () ->
		helper.extendDefaultTimeout this
		id = 'injector.failure'
		socket =
		before () ->
			socket = helper.getIo()
			seed = {}
			seed.url = 'http://test.com'
			client.post '/seeds', seed, (err, req, res, data) ->
		
		it 'should fail injector job, and injector status updated to indicate the status to complete', (done) ->
			body = {}
			body.identifier = id
			socket.on helper.nutchJobStatus, (msg) ->
				# Since Socket IO emits message to all clients, we are only 
				# interested in the message that corresponds to our test case,
				# hence the test verification is done only if the message has the
				# same id sent for the nutch process.
				if (msg.id is id)
					expect(msg.status).to.equal(db.jobStatus.FAILURE)			
					nutchCommons.findLatestJobStatus id, db.jobStatus.INJECTOR, (status) ->
						expect(status).to.equal(db.jobStatus.FAILURE)
						done()

			client.post '/crawler/inject', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
