restify = require 'restify'
db = require '../repositories/seeds.coffee'

remove = (req, res, next) ->
	id = req.params.id
	urlToRemove = {}
	urlToRemove._id = id
	db.seeds.remove urlToRemove, {}, (err, numRemoved) ->
		if err
			InternalError "Internal Server Error. URL not removed."
		res.status 204
		res.send ''
		next()

get = (req, res, next) ->
	db.seeds.find {}, (err, docs) ->
		urls = []
		for i, doc of docs
			url = {}
			url.id = doc._id
			url.url = doc.url
			urls.push url
		res.status 200
		res.send urls
		next()

create = (req, res, next) ->
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
		newUrl.id = doc._id
		newUrl.url = doc.url
		res.status 201
		res.send newUrl
		next()

update = (req, res, next) ->
	id = req.params.id
	payload = JSON.parse req.body
	if !payload? || !payload.url?
		next new restify.InvalidArgumentError('URL to update is missing in the payload')
	query = {}
	query._id = id
	seedToUpdate = {}
	urlToUpdate = {}
	urlToUpdate.url = payload.url
	seedToUpdate.$set = urlToUpdate
	db.seeds.update query, seedToUpdate, {}, (err, numReplaced) ->
		if numReplaced < 1
			next new restify.ResourceNotFoundError('Seed with ID:' + id + ' does not exist')
		else
			res.status 204
			res.send ''
			next()


exports.get = get
exports.create = create
exports.remove = remove
exports.update = update