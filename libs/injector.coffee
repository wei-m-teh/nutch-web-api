async = require 'async'
winston = require 'winston'
db = require '../repositories/db.coffee'
nutchUtils = require './nutchUtils.coffee'
seeder = require './seeds.coffee'

inject = (req, res, next) ->
	nutchUtils.extractIdentifier req, (identifier, err) ->
		if err
			next err
		else
			doInject identifier, res, next

doInject = (identifier, res, next) ->

	populateSeeds = (callback) ->
		seeder.populateSeedFile identifier, callback

	processJobStatus = (callback) ->
		nutchUtils.populateJobStatus identifier, db.jobStatus.INJECTOR, callback

	processHttpResponse = (callback) ->
		nutchUtils.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err?
			seeder.removeSeedFile identifier
			next err
		else 
			jobParams  = populateInjectorOptionsAndArguments identifier
			nutchUtils.executeJob jobParams, identifier, db.jobStatus.INJECTOR
			# listens for the event for job completion, then cleans up the seed file for the given job identifier. 
			nutchUtils.eventEmitter.once db.jobStatus.INJECTOR, (msg) ->
				seeder.removeSeedFile msg.id
			next()

	processJob = (err) ->
		if err
			seeder.removeSeedFile identifier
			next err
		else
			async.parallel [ processHttpResponse ], kickoffJob

	async.series [ populateSeeds, processJobStatus ], processJob 


populateInjectorOptionsAndArguments = (identifier) ->
	configuration = nutchUtils.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'inject'
	processArgs.push seeder.getSeedFile identifier
	processArgs.push '-crawlId' 
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions


exports.inject = inject
exports.doInject = doInject