async = require 'async'
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'

fetch = (identifier, batchId, res, next) ->
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.FETCHER, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		jobParams  = populateFetcherOptionsAndArguments identifier, batchId
		nutchCommons.executeJob jobParams, identifier, db.jobStatus.FETCHER
		next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob

# $bin/nutch fetch $commonOptions -D fetcher.timelimit.mins=$timeLimitFetch $batchId -crawlId $CRAWL_ID -threads 50
populateFetcherOptionsAndArguments = (identifier, batchId) ->
	# time limit for feching
	timeLimitFetch = 180
	configuration = nutchCommons.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'fetch'
	processArgs.push nutchCommons.commonOptions
	processArgs.push '-D' 
	processArgs.push 'fetcher.timelimit.mins=' + timeLimitFetch
	processArgs.push batchId
	processArgs.push '-crawlId'
	processArgs.push identifier
	processArgs.push '-threads'
	processArgs.push 50
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.fetch = fetch