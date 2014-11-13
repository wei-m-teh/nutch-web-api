async = require 'async'
db = require '../repositories/db.coffee'
nutchUtils = require './nutchUtils.coffee'

update = (req, res, next) ->
	nutchUtils.extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			doUpdate identifier, res, next

doUpdate = (identifier, res, next) ->
	processJobStatus = (callback) ->
		nutchUtils.populateJobStatus identifier, db.jobStatus.UPDATEDB, callback

	processHttpResponse = (callback) ->
		nutchUtils.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		else
			jobParams  = populateUpdateDbOptionsAndArguments identifier
			nutchUtils.executeJob jobParams, identifier, db.jobStatus.UPDATEDB
			next()

	processJob = (err) ->
		if err
			next err
		else
			async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob

#  $bin/nutch updatedb $commonOptions -crawlId $CRAWL_ID
populateUpdateDbOptionsAndArguments = (identifier) ->
	configuration = nutchUtils.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'updatedb'
	processArgs.push nutchUtils.populateCommonOptions({})...
	processArgs.push '-crawlId'
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.update = update
exports.doUpdate = doUpdate
