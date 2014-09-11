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

describe '/crawler/solr-delete-duplicates', () ->
	describe 'POST /crawler/solr-delete-duplicates successfully', () ->
		it 'should submit solr-delete-duplicates job successfully, resulted in 202 status code and the nutch-status table is populated accordingly', (done) ->
			client.post '/crawler/solr-delete-duplicates', {}, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get '/nutch-status' + '?identifier=' + db.jobStatus.SOLRDELETEDUPS + '&jobName=' + db.jobStatus.SOLRDELETEDUPS,  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
describe '/crawler/solr-delete-duplicates', () ->
	describe 'POST /crawler/solr-delete-duplicates', () ->
		before (done) ->
			jobStatusToUpdate = {}
			jobStatusToUpdate.jobName = db.jobStatus.SOLRDELETEDUPS
			jobStatusToUpdate.status = db.jobStatus.IN_PROGRESS
			jobStatusToUpdate.identifier = db.jobStatus.SOLRDELETEDUPS
			jobStatusToUpdate.date = Date.now()
			db.get('nutchStatus').insert jobStatusToUpdate, (err, doc) ->
				done(err)

		it 'should NOT submit solr-delete-duplicates job successfully, when another solr-delete-duplicates job is in progress', (done) ->
			client.post '/crawler/solr-delete-duplicates', {}, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()
