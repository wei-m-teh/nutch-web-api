restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()
socket =

before (done) ->
	db.get('nutchStatus').remove {}, {multi:true}
	done()

afterEach (done) ->
	db.get('nutchStatus').remove {}, {multi:true} 
	done()

describe '/nutch/parse', () ->
	describe 'POST /nutch/parse successfully', () ->
		it 'should submit parser job successfully, resulted in 202 status code and parser status table populated', (done) ->
			body = {}
			body.identifier = 'testParser'
			client.post '/nutch/parse', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get "/nutch/status?identifier=#{db.jobStatus.PARSER}&jobName=#{db.jobStatus.PARSER}",  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/nutch/parse', () ->
	describe 'POST /nutch/parse without an identifier', () ->
		it 'should NOT submit parser job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/nutch/parse', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()


describe '/nutch/parse', () ->
	describe 'POST /nutch/parse', () ->
		id = 'testParser.InProgress'
		before (done) ->
			jobStatusToUpdate = {}
			jobStatusToUpdate.jobName = db.jobStatus.PARSER
			jobStatusToUpdate.status = db.jobStatus.IN_PROGRESS
			jobStatusToUpdate.identifier = id
			jobStatusToUpdate.date = Date.now()
			db.get('nutchStatus').insert jobStatusToUpdate, (err, doc) ->
				done(err)

		it 'should NOT submit parser job successfully, when another parser job is in progress', (done) ->
			body = {}
			body.identifier = id
			client.post '/nutch/parse', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

describe 'POST /nutch/parse', () ->
	helper.extendDefaultTimeout this
	id = 'parser.success'
	before () ->
		socket = helper.getIo()
	
	it 'should complete the parser job successfully, and nutch job status updated to reflect the SUCCESS status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			helper.verifyJobStatus id, msg, db.jobStatus.PARSER, db.jobStatus.SUCCESS, () ->
					done()

		client.post '/nutch/parse', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)

describe 'POST /nutch/parse', () ->
	helper.extendDefaultTimeout this
	id = 'parser.failure'
	before () ->
		socket = helper.getIo()
	
	it 'should fail parser job, and nutch job status updated to reflect the FAILURE status', (done) ->
		body = {}
		body.identifier = id
		socket.on helper.nutchJobStatus, (msg) ->
			helper.verifyJobStatus id, msg, db.jobStatus.PARSER, db.jobStatus.FAILURE, () ->
					done()

		client.post '/nutch/parse', body, (err, req, res, data) ->
			expect(res.statusCode).to.equal(202)


