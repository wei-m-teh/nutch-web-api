restify = require 'restify'
util = require 'util'

class ConflictError extends restify.RestError
	constructor: (@message) ->
		restify.RestError.call this, {
			restCode: 'ConflictError',
			statusCode: 409,
			message: message,
			constructorOpt: ConflictError
		}
	this.name = 'ConflictError'	
	

module.exports = ConflictError