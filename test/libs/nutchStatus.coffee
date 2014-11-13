expect = require('chai').expect
should = require('chai').should()
assert = require('chai').assert
db = require '../../repositories/db.coffee'
helper = require './helper.coffee'
client = helper.getClient()

before () ->
	db.get('nutchStatus').remove {}, {multi:true}

afterEach () ->
	db.get('nutchStatus').remove {}, {multi:true} 	


describe '/nutch/status', () ->
	describe 'GET /nutch/status', () ->
		it 'should obtain the matching nutch status when both identifier and jobName are provided', (done) ->
			nutchStatus = {}
			nutchStatus.identifier = 'testNutchStatus_0'
			nutchStatus.jobName = 'testNutchJob_0'
			db.get("nutchStatus").insert nutchStatus, (err, doc) ->	
				client.get "/nutch/status?identifier=#{nutchStatus.identifier}&jobName=#{nutchStatus.jobName}", (err, req, res, data) ->
					expect(res.statusCode).to.equal(200)
					expect(data.length).to.equal(1)
					expect(data[0].identifier).to.equal(nutchStatus.identifier)
					expect(data[0].jobName).to.equal(nutchStatus.jobName)
					done()

		it 'should obtain all nutch statuses when no query params are provided', (done) ->
			nutchStatus_0 = {}
			nutchStatus_0.identifier = 'testNutchStatus_0'
			nutchStatus_0.jobName = 'testNutchJob_0'
			db.get("nutchStatus").insert nutchStatus_0, (err, doc) ->	
				nutchStatus_1 = {}
				nutchStatus_1.identifier = 'testNutchStatus_1'
				nutchStatus_1.jobName = 'testNutchJob_1'
				db.get("nutchStatus").insert nutchStatus_1, (err, doc) ->	
					client.get "/nutch/status", (err, req, res, data) ->
						expect(res.statusCode).to.equal(200)
						expect(data.length).to.equal(2)
						done()