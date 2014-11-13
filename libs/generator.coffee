async = require 'async'
db = require '../repositories/db.coffee'
nutchUtils = require './nutchUtils.coffee'


generate = (req, res, next) ->
	nutchUtils.extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			nutchUtils.extractBatchId req, (batchId) ->
				doGenerate identifier, batchId, res, next

doGenerate = (identifier, batchId, res, next) ->
	processJobStatus = (callback) ->
		nutchUtils.populateJobStatus identifier, db.jobStatus.GENERATOR, callback

	processHttpResponse = (callback) ->
		nutchUtils.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		else 
			jobParams  = populateGeneratorOptionsAndArguments identifier, batchId
			nutchUtils.executeJob jobParams, identifier, db.jobStatus.GENERATOR
			next()

	processJob = (err) ->
		if err
			next err
		else
			async.parallel [ processHttpResponse ], kickoffJob

	async.series [ processJobStatus ], processJob

populateGeneratorOptionsAndArguments = (identifier, batchId) ->
	numSlaves = 1
	sizeFetchList = numSlaves * 50000
	addDays = 0
	configuration = nutchUtils.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'generate'
	processArgs.push nutchUtils.populateCommonOptions({})...
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
exports.doGenerate = doGenerate