async = require 'async'
nconf = require 'nconf'
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'

index = (identifier, res, next) ->
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.SOLRINDEX, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		jobParams  = populateSolrIndexOptionsAndArguments identifier
		nutchCommons.executeJob jobParams, identifier, db.jobStatus.SOLRINDEX
		next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob

deleteDuplicates = (res, next) ->
	identifier = db.jobStatus.SOLRDELETEDUPS
	processJobStatus = (callback) ->
		nutchCommons.populateJobStatus identifier, db.jobStatus.SOLRDELETEDUPS, callback

	processHttpResponse = (callback) ->
		nutchCommons.submitHttpResponse identifier, res, callback

	kickoffJob = (err, result) ->
		if err
			next err
		jobParams  = populateSolrDeleteDuplicatesOptionsAndArguments
		nutchCommons.executeJob jobParams, identifier, db.jobStatus.SOLRDELETEDUPS
		next()

	processJob = (err) ->
		if err
			next err
		async.parallel [ processHttpResponse ], kickoffJob
	
	async.series [ processJobStatus ], processJob

#  $bin/nutch solrindex $commonOptions $SOLRURL -all -crawlId $CRAWL_ID
populateSolrIndexOptionsAndArguments = (identifier) ->
	solrUrl = nconf.get 'SOLR_URL'
	configuration = nutchCommons.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'solrindex'
	processArgs.push nutchCommons.commonOptions
	processArgs.push solrUrl
	processArgs.push '-all'
	processArgs.push '-crawlId'
	processArgs.push identifier
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

# $bin/nutch solrdedup $commonOptions $SOLRURL
populateSolrDeleteDuplicatesOptionsAndArguments = () ->
	solrUrl = nconf.get 'SOLR_URL'
	configuration = nutchCommons.configureEnvironment()
	options = {}
	options.cwd = configuration.workingDir
	processArgs = []
	processArgs.push 'solrdedup'
	processArgs.push nutchCommons.commonOptions
	processArgs.push solrUrl
	jobOptions = {}
	jobOptions.options = options
	jobOptions.arguments = processArgs
	return jobOptions

exports.index = index
exports.deleteDuplicates = deleteDuplicates