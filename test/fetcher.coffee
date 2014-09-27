restify = require 'restify'
nconf = require 'nconf'
sleep = require 'sleep'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
nutchCommons = require '../routes/nutchCommons.coffee'
client = helper.getClient()
socket =

before () ->
	db.get('nutchStatus').remove {}, {multi:true}

afterEach () ->
	db.get('nutchStatus').remove {}, {multi:true} 

describe '/crawler/fetch', () ->
	describe 'POST /crawler/fetch successfully', () ->
		it 'should submit fetcher job successfully, resulted in 202 status code and fetcher status table populated', (done) ->
			body = {}
			body.identifier = 'testFetcher'
			client.post '/crawler/fetch', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get '/nutch-status' + '?identifier=' + body.identifier + '&jobName=' + db.jobStatus.FETCHER,  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/crawler/fetch', () ->
	describe 'POST /crawler/fetch without an identifier', () ->
		it 'should NOT submit fetcher job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/crawler/fetch', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()


describe '/crawler/fetch', () ->
	describe 'POST /crawler/fetch', () ->
		id = 'testFetcher.inProgress'
		before (done) ->
			fetcherStatus = {}
			fetcherStatus.jobName = db.jobStatus.FETCHER
			fetcherStatus.status = db.jobStatus.IN_PROGRESS
			fetcherStatus.identifier = id
			fetcherStatus.date = Date.now()
			db.get('nutchStatus').insert fetcherStatus, (err, doc) ->
				done(err)

		it 'should NOT submit fetcher job successfully, when another fetcher job is in progress', (done) ->
			body = {}
			body.identifier = id
			client.post '/crawler/fetch', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

describe 'POST /crawler/fetch', () ->
	helper.extendDefaultTimeout this
	id = 'fetcher.success'
	before () ->
		socket = helper.getIo()
	
	it 'should complete fetcher job successfully, and nutch job status updated to reflect the SUCCESS status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			# Since Socket IO emits message to all clients, we are only 
			# interested in the message that corresponds to our test case,
			# hence the test verification is done only if the message has the
			# same id sent for the nutch process.
			if (msg.id is id)
				expect(msg.status).to.equal(db.jobStatus.SUCCESS)
				nutchCommons.findLatestJobStatus id, db.jobStatus.FETCHER, (status) ->
					expect(status).to.equal(db.jobStatus.SUCCESS)
					done()

		client.post '/crawler/fetch', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

describe 'POST /crawler/generate', () ->
	helper.extendDefaultTimeout this
	id = 'fetcher.failure'
	before () ->
		socket = helper.getIo()
	
	it 'should fail fetcher job, and nutch job status updated to reflect the FAILURE status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			# Since Socket IO emits message to all clients, we are only 
			# interested in the message that corresponds to our test case,
			# hence the test verification is done only if the message has the
			# same id sent for the nutch process.
			if (msg.id is id)
				expect(msg.status).to.equal(db.jobStatus.FAILURE)
				nutchCommons.findLatestJobStatus id, db.jobStatus.FETCHER, (status) ->
					expect(status).to.equal(db.jobStatus.FAILURE)
					done()

		client.post '/crawler/parse', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

