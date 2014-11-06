restify = require 'restify'
spawn = require('child_process').spawn
nconf = require 'nconf'
winston = require 'winston'
db = require '../repositories/db.coffee'
server = require '../server.coffee'
fs = require 'fs'
io = require('socket.io-client')
urlResolver = require('url')
events = require('events')
eventEmitter = new events.EventEmitter()
eventEmitter.setMaxListeners 500
hostname = nconf.get 'SERVER_HOST'
port = nconf.get 'SERVER_PORT'
serverUrl = {}
serverUrl.protocol = 'http'
serverUrl.hostname = hostname
serverUrl.port = port

# set the number of slaves nodes
numSlaves = 1
numTasks = numSlaves * 2
sizeFetchlist = numSlaves * 50000
NUTCH_APP_NAME = 'nutch'
NUTCH_JOB_STATUS = 'nutchJobStatus'

commonOptions = {}
commonOptions['mapred.reduce.tasks'] = numTasks
commonOptions['mapred.child.java.opts'] = '-Xmx1000m'
commonOptions['mapred.reduce.tasks.speculative.execution'] = 'false'
commonOptions['mapred.map.tasks.speculative.execution'] = 'false'
commonOptions['mapred.compress.map.output'] = 'true'

getIo = () ->
	socket = io.connect urlResolver.format serverUrl, {'reconnection delay' : 0, 'reopen delay' : 0, 'force new connection' : true }

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
	if res 
		response = {}
		response.message =  "injector job submitted successfully"
		response.status  = 202
		response.identifier = identifier
		res.status 202
		res.send response
		callback null
	else 
		callback null

createLocationHeader = (res, identifier) ->
	locationUrl = {}
	locationUrl.protocol = 'http:'
	locationUrl.host = res.req.headers.host
	locationUrl.pathname = "#{res.req.url}/#{identifier}"
	res.header "Location",  urlResolver.format locationUrl
	return
	
executeJob = (jobParams, identifier, jobName) ->
	jobExecutor = spawn NUTCH_APP_NAME, jobParams.arguments, jobParams.options
	jobExecutor.stdout.on 'data', (data) ->
		winston.info "For JobName: #{jobName}, Identifier: #{identifier}, #{data} \n"
		return
	
	jobExecutor.stderr.on 'error', (data) ->
		winston.error "For JobName: #{jobName}, Identifier: #{identifier}, #{data} \n"
		updateJobStatus identifier, db.jobStatus.FAILURE, jobName
		return

	jobExecutor.on 'close', (code) ->
		winston.info "For JobName: #{jobName}, Identifier: #{identifier}, job exited with code #{code}"
		if code is 0 then jobStatus = db.jobStatus.SUCCESS else jobStatus = db.jobStatus.FAILURE
		updateJobStatus identifier, jobStatus, jobName, (err) ->
			jobStatus = db.jobStatus.FAILURE if err?
			emitStatusEvents identifier, jobStatus, jobName
		return

	testJobExecutor = spawn 'sh', ['hello.sh'], { 'cwd' : './test/bin'}
	testJobExecutor.stdout.on 'data', (data) ->
		winston.info "For hello.sh, #{data} \n"
		return

emitStatusEvents = (identifier, jobStatus, jobName) ->
	ioJobStatus = {}
	ioJobStatus.name = jobName
	ioJobStatus.id = identifier
	ioJobStatus.status = jobStatus
	server.getIo().sockets.emit NUTCH_JOB_STATUS, ioJobStatus
	eventEmitter.emit jobName, ioJobStatus


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

extractIdentifier = (req, next) ->
	if !req.body 
		next null, new restify.InvalidArgumentError("request body not found")
		return	
	
	identifier = req.body.identifier
	if !identifier
		next null, new restify.InvalidArgumentError("identifier not found")
		return
	next identifier, null

extractBatchId = (req, next) ->
	if req.body 
		batchId = req.body.batchId
		if !batchId
			batchId = generateBatchId()
	else 
		batchId = generateBatchId()
	next batchId

generateBatchId = () ->
	now = new Date()
	now.getTime()
	

exports.updateJobStatus = updateJobStatus
exports.populateSeeds = populateSeeds
exports.populateJobStatus = populateJobStatus
exports.submitHttpResponse = submitHttpResponse
exports.createLocationHeader = createLocationHeader
exports.executeJob = executeJob
exports.configureEnvironment = configureEnvironment
exports.commonOptions = commonOptions
exports.findLatestJobStatus = findLatestJobStatus
exports.populateCommonOptions = populateCommonOptions
exports.getIo = getIo
exports.nutchJobStatus = NUTCH_JOB_STATUS
exports.eventEmitter = eventEmitter
exports.extractIdentifier = extractIdentifier
exports.extractBatchId = extractBatchId
exports.generateBatchId = generateBatchId
