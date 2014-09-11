async = require 'async'
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'


parse = (identifier, batchId, res, next) ->
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.PARSER, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		jobParams  = populateParserOptionsAndArguments identifier, batchId
		nutchCommons.executeJob jobParams, identifier, db.jobStatus.PARSER
		next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob
	
# $bin/nutch parse $commonOptions $skipRecordsOptions $batchId -crawlId $CRAWL_ID
populateParserOptionsAndArguments = (identifier, batchId) ->
	mapredSkipAttemptsToStartSkipping = 2
	mapredSkipMapMaxSkipRecords = 1
	configuration = nutchCommons.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'parse'
	processArgs.push nutchCommons.commonOptions
	processArgs.push '-D' 
	processArgs.push 'mapred.skip.attempts.to.start.skipping=' + mapredSkipAttemptsToStartSkipping
	processArgs.push '-D' 
	processArgs.push 'mapred.skip.map.max.skip.records=' + mapredSkipMapMaxSkipRecords
	processArgs.push batchId
	processArgs.push '-crawlId'
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.parse = parse