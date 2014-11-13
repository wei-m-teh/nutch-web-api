restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
db = require '../../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()

before () ->
	db.get('seeds').remove {}, {multi:true} 	

afterEach () ->
	db.get('seeds').remove {}, {multi:true} 	

describe '/nutch/seeds', () ->
# Testing a successful HTTP status code
	describe 'GET /nutch/seeds', () ->
		it 'should get a 200 response statusCode when fetching all seeds', (done) ->
			client.get '/nutch/seeds', (err, req, res, data) ->
				expect(res.statusCode).to.equal(200)
				done()

	describe 'POST /nutch/seeds', () ->
		it 'should get a 201 response statusCode when new seed is created', (done) ->
			seed = {}
			seed.identifier = 'testSeed.success'
			seed.urls = [ 'http://test.com' ]
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				expect(res.statusCode).to.equal(201)
				done()
	
		it 'should get a 409 response statusCode when duplicate seed creation is attempted', (done) ->
			seed = {}
			seed.identifier = 'testSeed.duplicate'
			seed.urls = [ 'http://test.com' ]
			client.post '/nutch/seeds', seed, (err, req, res, data) ->
				client.post '/nutch/seeds', seed, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					done()

	describe 'PUT /nutch/seeds', () ->
		id = 'testSeed.update.success'
		seed = {}
		seed.identifier = id
		seed.urls = [ 'http://test.com' ]
		before ()->
			client.post '/nutch/seeds', seed, (err, req, res, data) ->

		it 'should get a 204 response statusCode when the existing seed is updated', (done) ->
			seed.urls = [ 'http://updated.test.com' ]
			client.put '/nutch/seeds/' + id, seed, (err, req, res, data) ->
				expect(res.statusCode).to.equal(204)
				client.get '/nutch/seeds/' + id, (err, req, res, data) ->
					expect(data.urls).to.eql(seed.urls)
					done()


	describe 'DELETE /nutch/seeds', () ->
		id = 'testSeed.delete.success'
		seed = {}
		seed.urls = [ 'http://test.com' ]
		before ()->
			client.post '/nutch/seeds', seed, (err, req, res, data) ->

		it 'should get a 204 response statusCode when the given seed is deleted', (done) ->
			client.del '/nutch/seeds/' + id, (err, req, res) ->
				expect(res.statusCode).to.equal(204)
				done()
