sys = require 'sys'
restify = require 'restify'
spawn = require('child_process').spawn
nconf = require 'nconf'
async = require 'async'
winston = require 'winston'
db = require '../repositories/db.coffee'
fs = require 'fs'

# set the number of slaves nodes
numSlaves = 1
numTasks = numSlaves * 2
sizeFetchlist = numSlaves * 50000

# time limit for feching
timeLimitFetch = 180

commonOptions='-D mapred.reduce.tasks=' + numTasks + '-D mapred.child.java.opts=-Xmx1000m -D mapred.reduce.tasks.speculative.execution=false -D mapred.map.tasks.speculative.execution=false -D mapred.compress.map.output=true'

inject = (req, res, next) ->
	if !req.body 
		next new restify.InvalidArgumentError("request body not found")	
	transformed = JSON.parse req.body
	if !transformed.identifier
		next new restify.InvalidArgumentError("identifier not found")

	identifier = transformed.identifier
	nutchHome = nconf.get 'NUTCH_HOME'
	javaHome = nconf.get 'JAVA_HOME'
	seedDir = nconf.get 'SEED_DIR'
	nutchOpts = nconf.get 'NUTCH_OPTS'

	if !nutchHome? || !javaHome?
		winston.error "JAVA_HOME or NUTCH_HOME is not set. Please make sure these variables are defined, then try again."
		next new restify.InternalError("Internal Server Error. Please contact system administrator")
	writeOption = {}
	writeOption.flags = 'w'
	
	latestJobStatus = -99
	if !seedDir? 
		seedDir = '/tmp'

	populateSeeds = (callback) ->
		db.seeds.find {}, (err, docs) ->
			stream = fs.createWriteStream seedDir + "/seed.txt"
			for i, doc of docs
				stream.write doc.url + "\n"
			stream.end()
			callback err
		return 

	findInjectorStatus = (callback) ->
		queryParam = {}
		queryParam.crawlId = identifier
		sortByDate = {}
		sortByDate.date = -1
		db.injectorStatus.find(queryParam).sort(sortByDate).exec (err, docs)->
			if docs.length > 0
				latestJobStatus = docs[0].status
			else
				latestJobStatus = -1
			callback err
		
	addInjectorStatus = (callback) ->
		if latestJobStatus isnt -1 and latestJobStatus isnt 1
			callback new restify.InternalError("Injector job cannot be submitted at this time. The injector job for this identifier is in progress.")
		finderData = {}
		finderData.crawlId = identifier
		options = {}
		options.upsert = true
		data = {}
		data.crawlId = identifier
		data.status = 0
		data.date = Date.now()
		db.injectorStatus.update finderData, data, options, (err, num, doc) ->
			if err
				callback new restify.InternalError("Internal Server Error. " + err.errorType)
			else
				callback null

	returnHttpStatus = (callback) ->
		response = {}
		response.message =  "injector job submitted successfully"
		response.status  = 202
		response.identifier = identifier
		res.status 202
		res.send response
		callback null

	processInjectorStatus = (callback) ->	
		capturesError = (err) ->
			callback err
		async.series [ findInjectorStatus, addInjectorStatus ], capturesError
		return

	kickoffJob = (err, result) ->
		if err
			next err

		workingDir = nutchHome + '/bin'	
		options = {}
		options.cwd = workingDir
		process.env.JAVA_HOME = javaHome if javaHome?
		process.env.NUTCH_OPTS = nutchOpts if nutchOpts?
		processArgs = []
		processArgs.push 'inject'
		processArgs.push seedDir + '/seed.txt'
		processArgs.push '-crawlId' 
		processArgs.push identifier
		finderData = {}
		finderData.crawlId = identifier
		updateData = {} 
		newStatus = {}
		updateData.$set = newStatus
		nutch = 'nutch'
		inject = spawn nutch, processArgs, options
		inject.stdout.on 'data', (data) ->
			winston.info data + '\n'
			return
		inject.stderr.on 'error', (data) ->
			winston.error 'stderr: ' + data
			newStatus.status = -1
			newStatus.date = Date.now()
			db.injectorStatus.update finderData, updateData, {}, (err, numReplaced) ->
				if err
					winston.error 'unable to update injector status'
			return
		inject.on 'close', (code) ->
			winston.info 'child process exited with code: ' + code
			newStatus.date = Date.now()
			if code is 0
				newStatus.status = 1
			else 
				newStatus.status = -1
			updateData.$set = newStatus
			db.injectorStatus.update finderData, updateData, {}, (err, numReplaced) ->
				if err
					winston.error 'unable to update injector status'
			return
		next()

	processInjectorJob = (err) ->
		if err
			next err
		async.parallel [ returnHttpStatus ], kickoffJob

	async.parallel [ populateSeeds, processInjectorStatus ], processInjectorJob 
	return

generate = (req, res, next) ->
	next()

fetch = (req, res, next) ->
	next()

parse = (req, res, next) ->
	next()

dbUpdate = (req, res, next) ->
	next()

solrIndex = (req, res, next) ->
	next()

solrDeleteDuplicates = (req, res, next) ->
	next()

exports.inject = inject
