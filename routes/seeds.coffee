restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
db = require '../repositories/db.coffee'
nutchCommons = require './nutchCommons.coffee'
ConflictError = require '../errors/ConflictError.coffee'

remove = (req, res, next) ->
	id = req.params.id
	seedsToRemove = {}
	seedsToRemove.id = id
	db.get('seeds').remove seedsToRemove, {}, (err, numRemoved) ->
		if err
			next new restify.InternalError 'Internal Server Error. URL not removed.'
		res.status 204
		res.send ''
		next()

getAll = (req, res, next) ->
	db.get('seeds').find {}, (err, docs) ->
		urls = []
		for i, doc of docs
			response = {}
			response.id = doc.id
			response.urls = doc.urls
		res.status 200
		res.send response
		next()

get = (req, res, next) ->
	id = req.params.id
	getParam = {}
	getParam.id = id
	db.get('seeds').find getParam, (err, docs) ->
		if err
			next new restify.ResourceNotFoundError 'resource with id: ' + id + 'cannot be found'
		response = {}
		response.id = docs[0]._id
		response.urls = docs[0].urls
		res.status 200
		res.send response
		next()


submitHttpResponse = (res, id, next) ->	
	sendHttpResponse = () ->
		nutchCommons.createLocationHeader res, id
		res.status 201
		res.send '' 
		next()

	return next new ConflictError 'Duplicate entry' if err?
	return sendHttpResponse() if res?
	next()

create = (req, res, next) ->
	return next() if !req.body?
	seeds = {}
	seeds.id = req.body.identifier
	seeds.urls = req.body.urls
	doCreate res, seeds, next

doCreate = (res, seeds, next) ->
	db.get('seeds').insert seeds, (err, doc) ->
		if err?
			next new ConflictError 'Duplicate entry'
		else	
			submitHttpResponse res, doc.id, (err) ->
				next err

update = (req, res, next) ->
	id = req.params.id
	payload = req.body
	if !payload? || !payload.urls?
		next new restify.InvalidArgumentError 'URL to update is missing in the payload'
	query = {}
	query.id = id
	seedsToUpdate = {}
	urlToUpdate = {}
	urlToUpdate.urls = payload.urls
	seedsToUpdate.$set = urlToUpdate
	db.get('seeds').update query, seedsToUpdate, {}, (err, numReplaced) ->
		if numReplaced < 1
			next new restify.ResourceNotFoundError 'Seed with ID:' + id + ' does not exist'
		else
			res.status 204
			res.send ''
			next()


exports.getAll = getAll
exports.get = get
exports.create = create
exports.doCreate = doCreate
exports.remove = remove
exports.update = update