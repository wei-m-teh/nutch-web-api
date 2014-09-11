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

describe '/crawler/updateDb', () ->
	describe 'POST /crawler/updateDb successfully', () ->
		it 'should submit updateDb job successfully, resulted in 202 status code and updateDb status table populated', (done) ->
			body = {}
			body.identifier = 'testUpdateDb'
			client.post '/crawler/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get '/nutch-status' + '?identifier=' + body.identifier + '&jobName=' + db.jobStatus.UPDATEDB,  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/crawler/updatedb', () ->
	describe 'POST /crawler/updatedb without an identifier', () ->
		it 'should NOT submit updatedb job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/crawler/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()


describe '/crawler/updatedb', () ->
	describe 'POST /crawler/updatedb', () ->
		id = 'testUpdateDb'
		before (done) ->
			jobStatusToUpdate = {}
			jobStatusToUpdate.jobName = db.jobStatus.UPDATEDB
			jobStatusToUpdate.status = db.jobStatus.IN_PROGRESS
			jobStatusToUpdate.identifier = id
			jobStatusToUpdate.date = Date.now()
			db.get('nutchStatus').insert jobStatusToUpdate, (err, doc) ->
				done(err)

		it 'should NOT submit updateDb job successfully, when another updateDb job is in progress', (done) ->
			body = {}
			body.identifier = id
			client.post '/crawler/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()
