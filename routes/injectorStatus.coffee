restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
db = require '../repositories/db.coffee'

getAll = (req, res, next) ->
	db.get('injectorStatus').find {}, (err, docs) ->
		if err
			next new restify.InternalError("Internal Server Error. " + err.errorType)
		jobStatuses = []
		for i, doc of docs
			jobStatus = {}
			jobStatus.id = doc._id
			jobStatus.crawlId = doc.crawlId
			jobStatus.status  = doc.status
			jobStatus.date = doc.date
			jobStatuses.push jobStatus
		res.status 200
		res.send jobStatuses
		next()


get = (req, res, next) ->
	id = req.params.id
	getParams = {}
	getParams.crawlId = id
	db.get('injectorStatus').find getParams, (err, docs) ->
		if err || docs.length < 1
			next new restify.ResourceNotFoundError 'resource with id: ' + id + ' cannot be found'
		injector = {}
		injector.identifier = docs[0].crawlId
		injector.status = docs[0].status
		injector.date = docs[0].date
		res.status 200
		res.send injector
		next()

exports.getAll = getAll
exports.get = get