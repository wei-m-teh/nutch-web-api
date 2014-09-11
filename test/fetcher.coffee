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
		id = 'testFetcher'
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
