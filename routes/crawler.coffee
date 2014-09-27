restify = require 'restify'
injector = require './injector.coffee'
generator = require './generator.coffee'
fetcher = require './fetcher.coffee'
parser = require './parser.coffee'
dbUpdater = require './dbUpdater.coffee'
solrIndexer = require './solrIndexer.coffee'

inject = (req, res, next) ->
	extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			injector.inject identifier, res, next

generate = (req, res, next) ->
	extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			extractBatchId req, (batchId) ->
				generator.generate identifier, batchId, res, next

fetch = (req, res, next) ->
	extractIdentifier req, (identifier, err) ->
		if err
			next err
		else 
			extractBatchId req, (batchId) ->
				fetcher.fetch identifier, batchId, res, next

parse = (req, res, next) ->
	extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			extractBatchId req, (batchId) ->
				parser.parse identifier, batchId, res, next

updateDb = (req, res, next) ->
	extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			dbUpdater.update identifier, res, next

solrIndex = (req, res, next) ->	
	extractIdentifier req, (identifier, err) ->
		if err
			next err	
		else
			solrIndexer.index identifier, res, next

solrDeleteDuplicates = (req, res, next) ->
	solrIndexer.deleteDuplicates res, next

extractIdentifier = (req, next) ->
	if !req.body 
		next null, new restify.InvalidArgumentError("request body not found")
		return	
	
	identifier = req.body.identifier
	if !identifier
		next null, new restify.InvalidArgumentError("identifier not found")
		return
	next identifier, null

extractBatchId = (req, next) ->
	if req.body 
		batchId = req.body.batchId
		if !batchId
			batchId = generateBatchId()
	else 
		batchId = generateBatchId()
	next batchId

generateBatchId = () ->
	now = new Date()
	now.getTime()
	
exports.inject = inject
exports.generate = generate
exports.fetch = fetch
exports.parse = parse
exports.updateDb = updateDb
exports.solrIndex = solrIndex
exports.solrDeleteDuplicates = solrDeleteDuplicates
