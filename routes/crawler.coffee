restify = require 'restify'
injector = require './injector.coffee'
generator = require './generator.coffee'
fetcher = require './fetcher.coffee'
parser = require './parser.coffee'
dbUpdater = require './dbUpdater.coffee'
solrIndexer = require './solrIndexer.coffee'

inject = (req, res, next) ->
	identifier = extractIdentifier req, next
	injector.inject identifier, res, next
	return

generate = (req, res, next) ->
	identifier = extractIdentifier req, next
	batchId = extractBatchId req
	generator.generate identifier, batchId, res, next
	return

fetch = (req, res, next) ->
	identifier = extractIdentifier req, next
	batchId = extractBatchId req
	fetcher.fetch identifier, batchId, res, next
	return


parse = (req, res, next) ->
	identifier = extractIdentifier req, next
	batchId = extractBatchId req
	parser.parse identifier, batchId, res, next
	return

updateDb = (req, res, next) ->
	identifier = extractIdentifier req, next
	dbUpdater.update identifier, res, next
	return

solrIndex = (req, res, next) ->	
	identifier = extractIdentifier req, next
	solrIndexer.index identifier, res, next
	return

solrDeleteDuplicates = (req, res, next) ->
	solrIndexer.deleteDuplicates res, next
	return

extractIdentifier = (req, next) ->
	if !req.body 
		next new restify.InvalidArgumentError("request body not found")
		return	
	
	identifier = req.body.identifier
	if !identifier
		next new restify.InvalidArgumentError("identifier not found")
		return
	identifier

extractBatchId = (req) ->
	if req.body 
		batchId = req.body.batchId
		if !batchId
			batchId = generateBatchId()
	else 
		generateBatchId()

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
