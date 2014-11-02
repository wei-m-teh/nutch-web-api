restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()
socket =

before () ->
	db.get('nutchStatus').remove {}, {multi:true}

afterEach () ->
	db.get('nutchStatus').remove {}, {multi:true} 

describe '/nutch/fetch', () ->
	describe 'POST /nutch/fetch successfully', () ->
		it 'should submit fetcher job successfully, resulted in 202 status code and fetcher status table populated', (done) ->
			body = {}
			body.identifier = 'testFetcher'
			client.post '/nutch/fetch', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get "/nutch/status?identifier=#{db.jobStatus.FETCHER}&jobName=#{db.jobStatus.FETCHER}",  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/nutch/fetch', () ->
	describe 'POST /nutch/fetch without an identifier', () ->
		it 'should NOT submit fetcher job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/nutch/fetch', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()


describe '/nutch/fetch', () ->
	describe 'POST /nutch/fetch', () ->
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
			client.post '/nutch/fetch', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

describe 'POST /nutch/fetch', () ->
	helper.extendDefaultTimeout this
	id = 'fetcher.success'
	before () ->
		socket = helper.getIo()
	
	it 'should complete fetcher job successfully, and nutch job status updated to reflect the SUCCESS status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			helper.verifyJobStatus id, msg, db.jobStatus.FETCHER, db.jobStatus.SUCCESS, () ->
				done()

		client.post '/nutch/fetch', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

describe 'POST /nutch/fetch', () ->
	helper.extendDefaultTimeout this
	id = 'fetcher.failure'
	before () ->
		socket = helper.getIo()
	
	it 'should fail fetcher job, and nutch job status updated to reflect the FAILURE status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			helper.verifyJobStatus id, msg, db.jobStatus.FETCHER, db.jobStatus.FAILURE, () ->
				done()

		client.post '/nutch/fetch', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

