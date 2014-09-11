restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
db = require '../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()

before () ->
	db.get('seeds').remove {}, {multi:true} 	

afterEach () ->
	db.get('seeds').remove {}, {multi:true} 	

describe '/seeds', () ->
# Testing a successful HTTP status code
	describe 'GET /seeds', () ->
		it 'should get a 200 response statusCode when fetching all seeds', (done) ->
			client.get '/seeds', (err, req, res, data) ->
				expect(res.statusCode).to.equal(200)
				done()

	describe 'POST /seeds', () ->
		it 'should get a 201 response statusCode when new seed is created', (done) ->
			seed = {}
			seed.url = 'http://test.com'
			client.post '/seeds', seed, (err, req, res, data) ->
				expect(res.statusCode).to.equal(201)
				expect(data.url).to.equal(seed.url)
				done()
	
	describe 'POST /seeds', () ->
		it 'should get a 409 response statusCode when duplicate seed creation is attempted', (done) ->
			seed = {}
			seed.url = 'http://test.com'
			client.post '/seeds', seed, (err, req, res, data) ->
				client.post '/seeds', seed, (err, req, res, data) ->
					expect(res.statusCode).to.equal(409)
					done()

	describe 'PUT /seeds', () ->
		seed = {}
		seed.url = 'http://test.com'
		seedId = ''
		before (done)->
			client.post '/seeds', seed, (err, req, res, data) ->
				if err
					done(err)
				seedId = data.id
				done()
		it 'should get a 204 response statusCode when the existing seed is updated', (done) ->
			seed.url = 'http://updated.test.com'
			client.put '/seeds/' + seedId, seed, (err, req, res, data) ->
				expect(res.statusCode).to.equal(204)
				client.get '/seeds/' + seedId, (err, req, res, data) ->
					expect(data.url).to.equal(seed.url)
					done()


	describe 'DELETE /seeds', () ->
		seed = {}
		seed.url = 'http://test.com'
		seedId = ''
		before (done)->
			client.post '/seeds', seed, (err, req, res, data) ->
				if err
					done(err)
				seedId = data.id
				done()
		it 'should get a 204 response statusCode when the given seed is deleted', (done) ->
			client.del '/seeds/' + seedId, (err, req, res) ->
				expect(res.statusCode).to.equal(204)
				done()
