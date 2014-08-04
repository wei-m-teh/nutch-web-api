restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
db = require '../repositories/db.coffee'

get = (req, res, next) ->
	db.injectorStatus.find {}, (err, docs) ->
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

exports.get = get