async = require 'async'
db = require '../repositories/db.coffee'
nutchUtils = require './nutchUtils.coffee'

parse = (req, res, next) ->
	nutchUtils.extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			nutchUtils.extractBatchId req, (batchId) ->
				doParse identifier, batchId, res, next

doParse = (identifier, batchId, res, next) ->
	processJobStatus = (callback) ->
		nutchUtils.populateJobStatus identifier, db.jobStatus.PARSER, callback

	processHttpResponse = (callback) ->
		nutchUtils.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		else 
			jobParams  = populateParserOptionsAndArguments identifier, batchId
			nutchUtils.executeJob jobParams, identifier, db.jobStatus.PARSER
			next()

	processJob = (err) ->
		if err
			next err
		else 
			async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob
	
# $bin/nutch parse $commonOptions $skipRecordsOptions $batchId -crawlId $CRAWL_ID
populateParserOptionsAndArguments = (identifier, batchId) ->
	mapredSkipAttemptsToStartSkipping = 2
	mapredSkipMapMaxSkipRecords = 1
	configuration = nutchUtils.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	#Populate java system properties for parser job
	parserOptions = {}
	parserOptions['mapred.skip.attempts.to.start.skipping'] = mapredSkipAttemptsToStartSkipping
	parserOptions['mapred.skip.map.max.skip.records'] = mapredSkipMapMaxSkipRecords
	processArgs = []
	processArgs.push 'parse'
	processArgs.push  nutchUtils.populateCommonOptions(parserOptions)...
	processArgs.push batchId
	processArgs.push '-crawlId'
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.parse = parse
exports.doParse = doParse