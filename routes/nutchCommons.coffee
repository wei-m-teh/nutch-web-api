restify = require 'restify'
spawn = require('child_process').spawn
nconf = require 'nconf'
winston = require 'winston'
db = require '../repositories/db.coffee'
server = require '../server.coffee'
fs = require 'fs'

# set the number of slaves nodes
numSlaves = 1
numTasks = numSlaves * 2
sizeFetchlist = numSlaves * 50000
NUTCH_APP_NAME = 'nutch'

commonOptions = {}
commonOptions['mapred.reduce.tasks'] = numTasks
commonOptions['mapred.child.java.opts'] = '-Xmx1000m'
commonOptions['mapred.reduce.tasks.speculative.execution'] = 'false'
commonOptions['mapred.map.tasks.speculative.execution'] = 'false'
commonOptions['mapred.compress.map.output'] = 'true'

populateCommonOptions = (jobOptions) ->
	args=[]
	for key, value of commonOptions
		args.push '-D'
		args.push "#{key}=#{value}"
	
	for key, value of jobOptions
		args.push '-D'
		args.push "#{key}=#{value}"
	return args

updateJobStatus = (identifier, jobStatus, jobName, next) ->
	newStatus = {}
	newStatus.status = jobStatus
	newStatus.date = Date.now()
	updateData = {}
	updateData.$set = newStatus
	finderData = {}
	finderData.identifier = identifier
	finderData.jobName = jobName
	db.get('nutchStatus').update finderData, updateData, {}, (err, numReplaced) ->
		if err
			winston.error 'unable to update job status' 
		next err
populateSeeds = (callback) ->
	if !seedDir
		seedDir = '/tmp'
	
	db.get('seeds').find {}, (err, docs) ->
		stream = fs.createWriteStream seedDir + "/seed.txt"
		for i, doc of docs
			stream.write doc.url + "\n"
		stream.end()
		callback err
	return 


populateJobStatus = (identifier, jobName, callback) ->
	addJobStatus = (latestJobStatus) ->
		if latestJobStatus isnt db.jobStatus.FAILURE and latestJobStatus isnt db.jobStatus.SUCCESS
			callback new restify.InvalidArgumentError('Job cannot be submitted at this time. The job for this identifier is in progress.')
		finderData = {}
		finderData.identifier = identifier
		finderData.jobName = jobName
		options = {}
		options.upsert = true
		data = {}
		data.identifier = identifier
		data.jobName = jobName
		data.status = db.jobStatus.IN_PROGRESS
		data.date = Date.now()
		db.get('nutchStatus').update finderData, data, options, (err, num, doc) ->
			if err
				callback new restify.InternalError("Internal Server Error. " + err.errorType)
			else
				callback null

	findLatestJobStatus identifier, jobName, addJobStatus
	return

findLatestJobStatus = (identifier, jobName, next) ->
	queryParam = {}
	queryParam.identifier = identifier
	queryParam.jobName = jobName
	sortByDate = {}
	sortByDate.date = -1
	latestJobStatus = -99
	db.get('nutchStatus').find(queryParam).sort(sortByDate).exec (err, docs)->
		if docs.length > 0
			latestJobStatus = docs[0].status
		else
			latestJobStatus = db.jobStatus.FAILURE
		next latestJobStatus

submitHttpResponse = (identifier, res, callback) ->
	response = {}
	response.message =  "injector job submitted successfully"
	response.status  = 202
	response.identifier = identifier
	res.status 202
	res.send response
	callback null

executeJob = (jobParams, identifier, jobName) ->
	jobExecutor = spawn NUTCH_APP_NAME, jobParams.arguments, jobParams.options
	ioJobStatus = {}
	ioJobStatus.name = jobName
	ioJobStatus.id = identifier
	jobExecutor.stdout.on 'data', (data) ->
		winston.info data + '\n'
		return
	
	jobExecutor.stderr.on 'error', (data) ->
		winston.error 'stderr: ' + data
		updateJobStatus identifier, db.jobStatus.FAILURE, jobName
		return

	jobExecutor.on 'close', (code) ->
		winston.info 'child process exited with code: ' + code
		if code is 0 then jobStatus = db.jobStatus.SUCCESS else jobStatus = db.jobStatus.FAILURE
		updateJobStatus identifier, jobStatus, jobName, (err) ->
			ioJobStatus.status = jobStatus
			server.getIo().sockets.emit 'nutchJobStatus', ioJobStatus
		return

configureEnvironment = () ->
	nutchHome = nconf.get 'NUTCH_HOME'
	javaHome = nconf.get 'JAVA_HOME'
	seedDir = nconf.get 'SEED_DIR'
	nutchOpts = nconf.get 'NUTCH_OPTS'
	workingDir = nutchHome + '/bin'	

	if !process.env.JAVA_HOME
		process.env.JAVA_HOME = javaHome if javaHome?

	if !process.env.NUTCH_OPTS
		process.env.NUTCH_OPTS = nutchOpts if nutchOpts?
	
	configuration = {}
	configuration.seedDir = seedDir
	configuration.workingDir = workingDir
	return configuration

exports.updateJobStatus = updateJobStatus
exports.populateSeeds = populateSeeds
exports.populateJobStatus = populateJobStatus
exports.submitHttpResponse = submitHttpResponse
exports.executeJob = executeJob
exports.configureEnvironment = configureEnvironment
exports.commonOptions = commonOptions
exports.findLatestJobStatus = findLatestJobStatus
exports.populateCommonOptions = populateCommonOptions

