restify = require 'restify'
nconf = require 'nconf'
sleep = require 'sleep'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()

before (done) ->
	db.get('nutchStatus').remove {}, {multi:true}
	done()

afterEach (done) ->
	db.get('nutchStatus').remove {}, {multi:true} 
	done()

describe '/crawler/parse', () ->
	describe 'POST /crawler/parse successfully', () ->
		it 'should submit parser job successfully, resulted in 202 status code and parser status table populated', (done) ->
			body = {}
			body.identifier = 'testParser'
			client.post '/crawler/parse', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get '/nutch-status' + '?identifier=' + body.identifier + '&jobName=' + db.jobStatus.PARSER,  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/crawler/parse', () ->
	describe 'POST /crawler/parse without an identifier', () ->
		it 'should NOT submit parser job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/crawler/parse', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()


describe '/crawler/parse', () ->
	describe 'POST /crawler/parse', () ->
		id = 'testParser'
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
			client.post '/crawler/parse', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()
