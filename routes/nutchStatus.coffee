db = require '../repositories/db.coffee'

find = (req, res, next) ->
	identifier = req.query.identifier
	jobName = req.query.jobName
	finderData = {}
	finderData.identifier = identifier if identifier?
	finderData.jobName = jobName if jobName?
	db.get('nutchStatus').find finderData, (err, docs) ->
		if err
			next new restify.InternalError("Internal Server Error. " + err.errorType)
		jobStatuses = []
		for i, doc of docs
			jobStatus = {}
			jobStatus.id = doc._id
			jobStatus.identifier = doc.identifier
			jobStatus.jobName = doc.jobName
			jobStatus.status  = doc.status
			jobStatus.date = doc.date
			jobStatuses.push jobStatus
		res.status 200
		res.send jobStatuses
		next()

getOne = (req, res, next) ->
	id = req.params.id
	getParams = {}
	getParams.identifier = id
	db.get('nutchStatus').find getParams, (err, docs) ->
		if err || docs.length < 1
			next new restify.ResourceNotFoundError 'resource with id: ' + id + ' cannot be found'
		jobStatus = {}
		jobStatus.identifier = docs[0].identifier
		jobStatus.jobName = docs[0].jobName
		jobStatus.status = docs[0].status
		jobStatus.date = docs[0].date
		res.status 200
		res.send jobStatus
		next()

exports.find = find
exports.getOne = getOne