async = require 'async'
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'

update = (identifier, res, next) ->
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.UPDATEDB, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		jobParams  = populateUpdateDbOptionsAndArguments identifier
		nutchCommons.executeJob jobParams, identifier, db.jobStatus.UPDATEDB
		next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob

#  $bin/nutch updatedb $commonOptions -crawlId $CRAWL_ID
populateUpdateDbOptionsAndArguments = (identifier) ->
	configuration = nutchCommons.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'updatedb'
	processArgs.push nutchCommons.commonOptions
	processArgs.push '-crawlId'
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.update = update
