async = require 'async'
db = require '../repositories/db.coffee'
nutchUtils = require './nutchUtils.coffee'

fetch = (req, res, next) ->
	nutchUtils.extractIdentifier req, (identifier, err) ->
		if err
			next err
		else 
			nutchUtils.extractBatchId req, (batchId) ->
				doFetch identifier, batchId, res, next

doFetch = (identifier, batchId, res, next) ->
	processJobStatus = (callback) ->
		nutchUtils.populateJobStatus identifier, db.jobStatus.FETCHER, callback

	processHttpResponse = (callback) ->
		nutchUtils.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		else
			jobParams  = populateFetcherOptionsAndArguments identifier, batchId
			nutchUtils.executeJob jobParams, identifier, db.jobStatus.FETCHER
			next()

	processJob = (err) ->
		if err
			next err
		else
			async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob

# $bin/nutch fetch $commonOptions -D fetcher.timelimit.mins=$timeLimitFetch $batchId -crawlId $CRAWL_ID -threads 50
populateFetcherOptionsAndArguments = (identifier, batchId) ->
	# time limit for feching
	timeLimitFetch = 180
	configuration = nutchUtils.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir

	#Populate java system properties for fetcher job
	fetcherOptions = {}
	fetcherOptions['fetcher.timelimit.mins'] = timeLimitFetch

	processArgs = []
	processArgs.push 'fetch'
	processArgs.push nutchUtils.populateCommonOptions(fetcherOptions)...
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
exports.doFetch = doFetch