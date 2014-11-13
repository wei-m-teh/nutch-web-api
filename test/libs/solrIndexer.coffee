restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
db = require '../../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()
socket = 
	
before (done) ->
	db.get('nutchStatus').remove {}, {multi:true}
	done()

afterEach (done) ->
	db.get('nutchStatus').remove {}, {multi:true} 
	done()

describe '/nutch/solr-index', () ->
	helper.extendDefaultTimeout this
	describe 'POST /nutch/solr-index successfully', () ->
		it 'should submit solr-index job successfully, resulted in 202 status code and solr-index status table populated', (done) ->
			body = {}
			body.identifier = 'testSolrIndex'
			client.post '/nutch/solr-index', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get "/nutch/status?identifier=#{body.identifier}&jobName=#{db.jobStatus.SOLRINDEX}",  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
		it 'should NOT submit solr-index job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/nutch/solr-index', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()

		it 'should NOT submit solr-index job successfully, when another solr-index job is in progress', (done) ->
			id = 'solrIndex.InProgress'
			jobStatusToUpdate = {}
			jobStatusToUpdate.jobName = db.jobStatus.SOLRINDEX
			jobStatusToUpdate.status = db.jobStatus.IN_PROGRESS
			jobStatusToUpdate.identifier = id
			jobStatusToUpdate.date = Date.now()
			db.get('nutchStatus').insert jobStatusToUpdate, (err, doc) ->
				body = {}
				body.identifier = id
				client.post '/nutch/solr-index', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()

		it 'should complete solr-index job successfully, and nutch job status updated to reflect the SUCCESS status', (done) ->
			id = 'solrindex.success'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.SOLRINDEX, db.jobStatus.SUCCESS, () ->
					done()

			client.post '/nutch/solr-index', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should fail solr-index job, and nutch job status updated to reflect the FAILURE status', (done) ->
			id = 'solr-index.failure'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.SOLRINDEX, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/solr-index', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

