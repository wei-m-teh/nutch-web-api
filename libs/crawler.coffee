async = require 'async'
restify = require 'restify'
winston = require 'winston'
seeder = require './seeds.coffee'
injector = require './injector.coffee'
generator = require './generator.coffee'
fetcher = require './fetcher.coffee'
parser = require './parser.coffee'
dbUpdater = require './dbUpdater.coffee'
solrIndexer = require './solrIndexer.coffee'
nutchUtils = require './nutchUtils.coffee'
db = require '../repositories/db.coffee'
server = require '../server.coffee'

crawl = (req, res, next) ->
	extractCrawlerParameters req, (identifier, limit, seeds, err) ->
		if err
			next err
		else
			nutchUtils.submitHttpResponse identifier, res, next
			doCrawl identifier, limit, seeds
		return
doCrawl = (identifier, limit, seeds) ->
	batchId = 
	seed = (callback) ->
		seedData = {}
		seedData.identifier = identifier
		seedData.urls = seeds
		seeder.doCreate null, seedData, callback
		
	inject = (callback) ->
		injector.doInject identifier, null, (err) ->
				callback err if err
		nutchUtils.eventEmitter.once db.jobStatus.INJECTOR, (msg) ->
			jobFailure = msg if msg.status is db.jobStatus.FAILURE 
			callback jobFailure

	generate = (callback) ->
		generator.doGenerate identifier, batchId, null, (err) ->
			callback err if err
		nutchUtils.eventEmitter.once db.jobStatus.GENERATOR, (msg) ->
			jobFailure = msg if msg.status is db.jobStatus.FAILURE 
			callback jobFailure

	fetch = (callback) ->
		fetcher.doFetch identifier, batchId, null, (err) ->
			callback err if err
		nutchUtils.eventEmitter.once db.jobStatus.FETCHER, (msg) ->
			jobFailure = msg if msg.status is db.jobStatus.FAILURE 
			callback jobFailure

	parse = (callback) ->
		parser.doParse identifier, batchId, null, (err) ->
			callback err if err 
		nutchUtils.eventEmitter.once db.jobStatus.PARSER, (msg) ->	
			jobFailure = msg if msg.status is db.jobStatus.FAILURE 
			callback jobFailure

	updateDb = (callback) ->
		dbUpdater.doUpdate identifier, null, (err) ->
			callback err if err
		nutchUtils.eventEmitter.once db.jobStatus.UPDATEDB, (msg) ->	
			jobFailure = msg if msg.status is db.jobStatus.FAILURE
			callback jobFailure

	solrIndex = (callback) ->
		solrIndexer.doIndex identifier, null, (err) ->
			callback err if err
		nutchUtils.eventEmitter.once db.jobStatus.SOLRINDEX, (msg) ->
			jobFailure = msg if msg.status is db.jobStatus.FAILURE
			callback jobFailure

	deleteDuplicates = (callback) ->
		solrIndexer.doDeleteDuplicates null, (err) ->
			callback err if err						
		nutchUtils.eventEmitter.once db.jobStatus.SOLRDELETEDUPS, (msg) ->
			jobFailure = msg if msg.status is db.jobStatus.FAILURE 
			callback jobFailure

	nutchJobs = (counter, callback) ->
		async.series [generate, fetch, parse, updateDb, solrIndex, deleteDuplicates],  (err, results) ->
			nutchUtils.eventEmitter.removeAllListeners db.jobStatus.GENERATOR
			nutchUtils.eventEmitter.removeAllListeners db.jobStatus.FETCHER
			nutchUtils.eventEmitter.removeAllListeners db.jobStatus.PARSER
			nutchUtils.eventEmitter.removeAllListeners db.jobStatus.UPDATEDB
			nutchUtils.eventEmitter.removeAllListeners db.jobStatus.SOLRINDEX
			nutchUtils.eventEmitter.removeAllListeners db.jobStatus.SOLRDELETEDUPS
			callback err

	processLoop = (callback) ->
		batchId = nutchUtils.generateBatchId()
		async.timesSeries limit, nutchJobs, (err, results) ->
			callback err 

	async.series [seed, inject, processLoop], (err, results) ->
		if err 
			winston.error "crawler job failed for identifier: #{identifier}"
		else 
			winston.info "crawler job completed successfully for identifier: #{identifier}"
	return

extractCrawlerParameters = (req, next) ->
	if !req.body 
		next null, null, null, new restify.InvalidArgumentError("request body not found")
		return	

	identifier = req.body.identifier
	if !identifier
		next null, null, null, new restify.InvalidArgumentError("identifier not found")
		return
	
	limit = req.body.limit
	if !limit
		next null, null, null, new restify.InvalidArgumentError("limit not found")
		return

	seeds = req.body.seeds
	if !seeds 
		next null, null, null, new restify.InvalidArgumentError("seeds not found")
		return

	next identifier, limit, seeds, null

exports.crawl = crawl