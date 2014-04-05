sys = require 'sys'
restify = require 'restify'
spawn = require('child_process').spawn
nconf = require 'nconf'
winston = require 'winston'
db = require '../repositories/seeds.coffee'
fs = require 'fs'

# set the number of slaves nodes
numSlaves = 1
numTasks = numSlaves * 2
sizeFetchlist = numSlaves * 50000

# time limit for feching
timeLimitFetch = 180

commonOptions='-D mapred.reduce.tasks=' + numTasks + '-D mapred.child.java.opts=-Xmx1000m -D mapred.reduce.tasks.speculative.execution=false -D mapred.map.tasks.speculative.execution=false -D mapred.compress.map.output=true'

inject = (req, res, next) ->
	if !req.body?
		next new restify.InvalidArgumentError("identifier not found")	
	transformed = JSON.parse req.body
	if transformed.identifier
		response = {}
		response.message =  "injector job submitted successfully for ID:" + transformed.identifier
		response.status  = 202
		response.identifier = transformed.identifier
		res.status 202
		res.send response
		next()
	else
		next new restify.InvalidArgumentError("identifier not found")
	
	nutchHome = nconf.get 'NUTCH_HOME'
	javaHome = nconf.get 'JAVA_HOME'
	seedDir = nconf.get 'SEED_DIR'
	nutchOpts = nconf.get 'NUTCH_OPTS'

	if !nutchHome? || !javaHome?
		winston.error "JAVA_HOME or NUTCH_HOME is not set. Please make sure these variables are defined, then try again."
		next new restify.InternalError("Internal Server Error. Please contact system administrator")
	writeOption = {}
	writeOption.flags = 'w'
	db.seeds.find {}, (err, docs) ->
		if !seedDir? 
			seedDir = '/tmp'
		stream = fs.createWriteStream seedDir + "/seed.txt"
		for i, doc of docs
			stream.write doc.url + "\n"
		stream.end()

	workingDir = nutchHome + '/bin'	
	options = {}
	options.cwd = workingDir
	process.env.JAVA_HOME = javaHome if javaHome?
	process.env.NUTCH_OPTS = nutchOpts if nutchOpts?
	processArgs = []
	processArgs.push 'inject'
	processArgs.push seedDir + '/seed.txt'
	processArgs.push '-crawlId' 
	processArgs.push transformed.identifier
	nutch = 'nutch'
	inject = spawn nutch, processArgs, options
	inject.stdout.on 'data', (data) ->
		winston.info '' + data
	inject.stderr.on 'data', (data) ->
		winston.error 'stderr: ' + data
	inject.on 'close', (code) ->
		winston.info 'child process exited with code ' + code

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
