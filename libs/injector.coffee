async = require 'async'
db = require '../repositories/db.coffee'
nutchUtils = require './nutchUtils.coffee'

inject = (req, res, next) ->
	nutchUtils.extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			doInject identifier, res, next

doInject = (identifier, res, next) ->
	processJobStatus = (callback) ->
		nutchUtils.populateJobStatus identifier, db.jobStatus.INJECTOR, callback

	processHttpResponse = (callback) ->
		nutchUtils.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		else 
			jobParams  = populateInjectorOptionsAndArguments identifier
			nutchUtils.executeJob jobParams, identifier, db.jobStatus.INJECTOR
			next()

	processJob = (err) ->
		if err
			next err
		else
			async.parallel [ processHttpResponse ], kickoffJob

	async.parallel [ nutchUtils.populateSeeds, processJobStatus ], processJob 

populateInjectorOptionsAndArguments = (identifier) ->
	configuration = nutchUtils.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'inject'
	processArgs.push configuration.seedDir + '/seed.txt'
	processArgs.push '-crawlId' 
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions


exports.inject = inject
exports.doInject = doInject