expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
db = require '../../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()

testSeeds = ['http://test1.com', 'http://test2.com']

before () ->
	db.get('nutchStatus').remove {}, {multi:true}
	db.get('seeds').remove {}, {multi:true} 	

afterEach () ->
	db.get('nutchStatus').remove {}, {multi:true} 	
	db.get('seeds').remove {}, {multi:true}	

describe '/nutch/crawl', () ->
	describe 'POST /nutch/crawl', () ->
		helper.extendDefaultTimeout this
		it 'should submit crawler job successfully, resulted in 202 status code', (done) ->
			body = {}
			body.identifier = 'testCrawler'
			body.seeds = testSeeds
			body.limit = 1
			client.post '/nutch/crawl', body, (err, req, res, data) ->
				if err
					done(err) 
				else
					expect(res.statusCode).to.equal(202)
					done()

		it 'should NOT submit the crawler job successfully, when the identifier is not provided in the request, and should resulted in 409 status code', (done) ->
			body = {}
			body.seeds = testSeeds
			body.limit = 1
			client.post '/nutch/crawl', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()

		it 'should NOT submit the crawler job successfully, when limit is not provided in the request, and should resulted in 409 status code', (done) ->
			body = {}
			body.seeds = testSeeds
			body.identifier = 'testCrawler.nolimit'
			client.post '/nutch/crawl', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()

		it 'should NOT submit the crawler job successfully, when seeds are not provided in the request, and should resulted in 409 status code', (done) ->
			body = {}
			body.identifier = 'testCrawler.nolimit'
			body.limit = 1
			client.post '/nutch/crawl', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()

		it 'should NOT submit the crawler job successfully, when no request body is provided in the request, and should resulted in 409 status code', (done) ->
			body = {}
			body.identifier = 'testCrawler.nobody'
			client.post '/nutch/crawl', body, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					expect(err.restCode).to.equal('InvalidArgument')
					done()

		it 'should complete crawler job successfully when injector job failed, and injector job status updated to indicate failure', (done) ->
			id = 'crawler.injector.failure'
			socket = helper.getIo()
			body = {}
			body.seeds = testSeeds
			body.identifier = id
			body.limit = 1
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.INJECTOR, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/crawl', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should complete crawler job successfully when injector job failed, and generator job status updated to indicate failure', (done) ->
			id = 'crawler.generator.failure'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			body.seeds = testSeeds
			body.limit = 1
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.GENERATOR, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/crawl', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should complete crawler job successfully when fetcher job failed, and generator job status updated to indicate failure', (done) ->
			id = 'crawler.fetcher.failure'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			body.seeds = testSeeds
			body.limit = 1
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.FETCHER, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/crawl', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should complete crawler job successfully when fetcher job failed, and parser job status updated to indicate failure', (done) ->
			id = 'crawler.parser.failure'
			socket = helper.getIo()

			body = {}
			body.identifier = id
			body.seeds = testSeeds
			body.limit = 1
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.PARSER, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/crawl', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should complete crawler job successfully when fetcher job failed, and updateDB job status updated to indicate failure', (done) ->
			id = 'crawler.updatedb.failure'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			body.seeds = testSeeds
			body.limit = 1
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.UPDATEDB, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/crawl', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)

		it 'should complete crawler job successfully when fetcher job failed, and solrindexer job status updated to indicate failure', (done) ->
			id = 'crawler.solrindexer.failure'
			socket = helper.getIo()
			body = {}
			body.identifier = id
			body.seeds = testSeeds
			body.limit = 1
			socket.on helper.nutchJobStatus, (msg) ->
				helper.verifyJobStatus id, msg, db.jobStatus.SOLRINDEX, db.jobStatus.FAILURE, () ->
					done()

			client.post '/nutch/crawl', body, (err, req, res, data) ->
				expect(res.statusCode).to.equal(202)
