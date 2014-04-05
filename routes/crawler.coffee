sys = require 'sys'
restify = require 'restify'
exec = require('child_process').exec
nconf = require 'nconf'
db = require '../repositories/seeds.coffee'
fs = require 'fs'

# set the number of slaves nodes
numSlaves = 1
numTasks = numSlaves * 2
sizeFetchlist = numSlaves * 50000

# time limit for feching
timeLimitFetch = 180

commonOptions='-D mapred.reduce.tasks=' + numTasks + '-D mapred.child.java.opts=-Xmx1000m -D mapred.reduce.tasks.speculative.execution=false -D mapred.map.tasks.speculative.execution=false -D mapred.compress.map.output=true'

# list = (req, res, next) ->
# 	nutch_home = nconf.get 'NUTCH_HOME'
# 	java_home = nconf.get 'JAVA_HOME'
# 	config = ''
# 	if nutch_home then config = 'NUTCH_HOME:' + nutch_home
# 	if java_home then config = config + 'JAVA_HOME:' + java_home
# 	res.send config
# 	next()

deleteUrl = (req, res, next) ->
	if !req.body?
		next()
	body = JSON.parse req.body
	url = body.url
	urlToRemove = {}
	urlToRemove.url = url
	db.seeds.remove urlToRemove, {}, (err, numRemoved) ->
		if err
			InternalError "Internal Server Error. URL not removed."
		res.status 204
		res.send ''
		next()

getUrls = (req, res, next) ->
	db.seeds.find {}, (err, docs) ->
		urls = []
		for i, doc of docs
			url = {}
			url.url = doc.url
			urls.push url
		res.status 200
		res.send urls
		next()

createUrl = (req, res, next) ->
	if !req.body?
		next()
	body = JSON.parse req.body
	url = body.url
	data = {}
	data.url = url
	db.seeds.insert data , (err, doc) ->
		if err
			InternalError "Internal Server Error."
		newUrl = {}
		newUrl.url = doc.url
		res.status 201
		res.send newUrl
		next()

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

	if !nutchHome? || !javaHome?
		console.log "JAVA_HOME or NUTCH_HOME is not set. Please make sure these variables are defined, then try again."
	writeOption = {}
	writeOption.flags = 'w'
	db.seeds.find {}, (err, docs) ->
		stream = fs.createWriteStream seedDir + "/seed.txt"
		for i, doc of docs
			stream.write doc.url + "\n"
		stream.end()
		


	# child = exec nutch_home + /runtime/local/bin/nutch , (error, stdout, stderr) ->
	# 	console.log 'stdout: ' + stdout
	# 	console.log 'stderr: ' + stderr
	# 	if  error != null
	# 		console.log 'exec error: ' + error
	# 	else
	# 		res.send('done');

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

#exports.list = list
exports.inject = inject
exports.getUrls = getUrls
exports.createUrl = createUrl
exports.deleteUrl = deleteUrl