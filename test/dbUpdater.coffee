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


describe '/nutch/updatedb', () ->
	describe 'POST /nutch/updatedb', () ->
		it 'should submit updateDb job successfully, resulted in 202 status code and updateDb status table populated', (done) ->
			body = {}
			body.identifier = 'testUpdateDb'
			client.post '/nutch/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
				client.get "/nutch/status?identifier=#{db.jobStatus.UPDATEDB}&jobName=#{db.jobStatus.UPDATEDB}",  (err, req, res, data) ->
					expect(data).to.exist
					done(err)
	
		it 'should NOT submit updatedb job successfully, when identifier is not provided, and should result in 409 status code', (done) ->
			body = {}
			client.post '/nutch/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(409)
				expect(err.restCode).to.equal('InvalidArgument')
				done()
		it 'should complete updatedb job successfully, and nutch job status updated to reflect the SUCCESS status', (done) ->
			id = 'updatedb.success'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.UPDATEDB, db.jobStatus.SUCCESS, () ->
					done()
			client.post '/nutch/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should fail fetcher job, and nutch job status updated to reflect the FAILURE status', (done) ->
			id = 'updatedb.failure'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.UPDATEDB, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/updatedb', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should NOT submit updateDb job successfully, when another updateDb job is in progress', (done) ->
			# setting up pre condition to which the job status is IN_PROGRESS.
			id = 'testUpdateDb.inProgress'
			jobStatusToUpdate = {}
			jobStatusToUpdate.jobName = db.jobStatus.UPDATEDB
			jobStatusToUpdate.status = db.jobStatus.IN_PROGRESS
			jobStatusToUpdate.identifier = id
			jobStatusToUpdate.date = Date.now()
			db.get('nutchStatus').insert jobStatusToUpdate, (err, doc) ->
				body = {}
				body.identifier = id
				client.post '/nutch/updatedb', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()
