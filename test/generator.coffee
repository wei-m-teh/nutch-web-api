restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
nutchCommons = require '../routes/nutchCommons.coffee'
client = helper.getClient()
socket =

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
		id = 'testGeneratorInProgress'
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

describe 'POST /crawler/generate', () ->
	helper.extendDefaultTimeout this
	id = 'generator.success'
	before () ->
		socket = helper.getIo()
	
	it 'should complete generator job successfully, and generator status updated to reflect the SUCCESS status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			# Since Socket IO emits message to all clients, we are only 
			# interested in the message that corresponds to our test case,
			# hence the test verification is done only if the message has the
			# same id sent for the nutch process.
			if (msg.id is id)
				expect(msg.status).to.equal(db.jobStatus.SUCCESS)
				nutchCommons.findLatestJobStatus id, db.jobStatus.GENERATOR, (status) ->
					expect(status).to.equal(db.jobStatus.SUCCESS)
					done()

		client.post '/crawler/generate', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

describe 'POST /crawler/generate', () ->
	helper.extendDefaultTimeout this
	id = 'generator.failure'
	before () ->
		socket = helper.getIo()
	
	it 'should fail generator job, and generator job status updated to reflect the FAILURE status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			# Since Socket IO emits message to all clients, we are only 
			# interested in the message that corresponds to our test case,
			# hence the test verification is done only if the message has the
			# same id sent for the nutch process.
			if (msg.id is id)
				expect(msg.status).to.equal(db.jobStatus.FAILURE)
				nutchCommons.findLatestJobStatus id, db.jobStatus.GENERATOR, (status) ->
					expect(status).to.equal(db.jobStatus.FAILURE)
					done()

		client.post '/crawler/generate', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)
