async = require 'async'
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'
server = require '../server.coffee'

inject = (identifier, res, next) ->
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.INJECTOR, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		jobParams  = populateInjectorOptionsAndArguments identifier
		nutchCommons.executeJob jobParams, identifier, db.jobStatus.INJECTOR
		next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob

	async.parallel [ nutchCommons.populateSeeds, processJobStatus ], processJob 

populateInjectorOptionsAndArguments = (identifier) ->
	configuration = nutchCommons.configureEnvironment()
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