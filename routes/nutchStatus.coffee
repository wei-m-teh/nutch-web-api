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
		else
			jobStatuses = []
			for i, doc of docs
				jobStatus = {}
				jobStatus.identifier = doc.identifier
				jobStatus.jobName = doc.jobName
				jobStatus.status  = doc.status
				jobStatus.date = doc.date
				jobStatuses.push jobStatus
			res.status 200
			res.send jobStatuses
			next()

exports.find = find
