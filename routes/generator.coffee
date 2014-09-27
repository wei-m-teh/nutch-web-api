async = require 'async'
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'

generate = (identifier, batchId, res, next) ->
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.GENERATOR, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		else 
			jobParams  = populateGeneratorOptionsAndArguments identifier, batchId
			nutchCommons.executeJob jobParams, identifier, db.jobStatus.GENERATOR
			next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob

	async.series [ processJobStatus ], processJob

populateGeneratorOptionsAndArguments = (identifier, batchId) ->
	numSlaves = 1
	sizeFetchList = numSlaves * 50000
	addDays = 0
	configuration = nutchCommons.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'generate'
	processArgs.push nutchCommons.commonOptions
	processArgs.push '-topN' 
	processArgs.push sizeFetchList
	processArgs.push '-noNorm'
	processArgs.push '-noFilter'
	processArgs.push '-addDays'
	processArgs.push addDays
	processArgs.push '-crawlId'
	processArgs.push identifier
	processArgs.push '-batchId'
	processArgs.push batchId
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.generate = generate