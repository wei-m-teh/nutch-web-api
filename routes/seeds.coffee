restify = require 'restify'
nconf = require 'nconf'
urlResolver = require('url')
db = require '../repositories/db.coffee'
ConflictError = require '../errors/ConflictError.coffee'

remove = (req, res, next) ->
	id = req.params.id
	urlToRemove = {}
	urlToRemove._id = id
	db.get('seeds').remove urlToRemove, {}, (err, numRemoved) ->
		if err
			next new restify.InternalError 'Internal Server Error. URL not removed.'
		res.status 204
		res.send ''
		next()

getAll = (req, res, next) ->
	db.get('seeds').find {}, (err, docs) ->
		urls = []
		for i, doc of docs
			url = {}
			url.id = doc._id
			url.url = doc.url
			urls.push url
		res.status 200
		res.send urls
		next()

get = (req, res, next) ->
	id = req.params.id
	getParam = {}
	getParam._id = id
	db.get('seeds').find getParam, (err, docs) ->
		if err
			next new restify.ResourceNotFoundError 'resource with id: ' + id + 'cannot be found'
		url = {}
		url.id = docs[0]._id
		url.url = docs[0].url
		res.status 200
		res.send url
		next()


submitHttpResponse = (req, res, newUrl, next) ->
	createLocationHeader = (req) ->
		locationUrl = {}
		locationUrl.protocol = 'http:'
		locationUrl.host = req.headers.host
		locationUrl.pathname = req.url + '/' + newUrl.id

	if err
		next new ConflictError 'Duplicate entry'
	else
		res.header "Location",  urlResolver.format createLocationHeader(req)
		res.status 201
		res.send newUrl
		next()

create = (req, res, next) ->
	if !req.body?
		next()
	else
		doCreate req.body, next

doCreate = (seeds, next) ->
	db.get('seeds').insert req.body, (err, doc) ->
		if err
			next new ConflictError 'Duplicate entry'
		else	
			newUrl = {}
			newUrl.id = doc._id
			newUrl.url = doc.url
			submitHttpResponse req, res, newUrl, next	

update = (req, res, next) ->
	id = req.params.id
	payload = req.body
	if !payload? || !payload.url?
		next new restify.InvalidArgumentError 'URL to update is missing in the payload'
	query = {}
	query._id = id
	seedToUpdate = {}
	urlToUpdate = {}
	urlToUpdate.url = payload.url
	seedToUpdate.$set = urlToUpdate
	db.get('seeds').update query, seedToUpdate, {}, (err, numReplaced) ->
		if numReplaced < 1
			next new restify.ResourceNotFoundError 'Seed with ID:' + id + ' does not exist'
		else
			res.status 204
			res.send ''
			next()


exports.getAll = getAll
exports.get = get
exports.create = create
exports.remove = remove
exports.update = update