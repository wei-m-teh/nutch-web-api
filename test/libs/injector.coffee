restify = require 'restify'
nconf = require 'nconf'
io = require('socket.io-client')
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
db = require '../../repositories/db.coffee'
helper = require './helper.coffee'

client = helper.getClient()
testSeeds = ['http://test.com']

before () ->
	db.get('nutchStatus').remove {}, {multi:true} 	
	db.get('seeds').remove {}, {multi:true} 	

afterEach () ->
	db.get('nutchStatus').remove {}, {multi:true} 	
	db.get('seeds').remove {}, {multi:true}	

describe '/nutch/inject', () ->
	helper.extendDefaultTimeout this
	describe 'POST /nutch/inject', () ->
		it 'should submit injector job successfully, resulted in 202 status code and injector status table populated', (done) ->
			id = 'testInjector'
			seed = {}
			seed.urls = testSeeds
			seed.identifier = id
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				body = {}
				body.identifier = id
				client.post '/nutch/inject', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(202)
					client.get "/nutch/status?identifier=#{db.jobStatus.INJECTOR}&jobName=#{db.jobStatus.INJECTOR}",  (err, req, res, data) ->
						expect(data).to.exist
						done()
				
		it 'should NOT submit injector job successfully, when identifier is not provided to the injector, and should result in 409 status code', (done) ->
			id = 'noIdTest'
			seed = {}
			seed.identifier = id
			seed.urls = testSeeds
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				body = {}
				client.post '/nutch/inject', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()
				
		it 'should NOT submit injector job successfully, when another injector job is in progress', (done) ->
			id = 'testInjector.inprogress'
			seed = {}
			seed.identifier = id
			seed.urls = [ 'http://test.com' ]
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				injectorStatus = {}
				injectorStatus.status = 0
				injectorStatus.identifier = id
				injectorStatus.jobName = db.jobStatus.INJECTOR
				injectorStatus.date = Date.now()
				db.get('nutchStatus').insert injectorStatus, (err, doc) ->
					body = {}
					body.identifier = id
					client.post '/nutch/inject', body, (err, req, res, data) ->
						expect(res.statusCode).to.equal(409)
						expect(err.restCode).to.equal('InvalidArgument')
						done()
	
		it 'should complete injector job successfully, and injector status updated to indicate the status to complete', (done) ->
			id = 'injector.success'
			socket = helper.getIo()
			seed = {}
			seed.identifier = id
			seed.urls = testSeeds
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				body = {}
				body.identifier = id
				socket.on helper.nutchJobStatus, (msg) ->
					helper.verifyJobStatus id, msg, db.jobStatus.INJECTOR, db.jobStatus.SUCCESS, () ->
						done()
				client.post '/nutch/inject', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(202)
		
		it 'should fail injector job, and injector status updated to indicate the status to complete', (done) ->
			id = 'injector.failure'
			socket = helper.getIo()
			seed = {}
			seed.identifier = id
			seed.urls = [ 'http://test.com' ]
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				body = {}
				body.identifier = id
				socket.on helper.nutchJobStatus, (msg) ->
					helper.verifyJobStatus id, msg, db.jobStatus.INJECTOR, db.jobStatus.FAILURE, () ->
						done()

				client.post '/nutch/inject', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(202)
