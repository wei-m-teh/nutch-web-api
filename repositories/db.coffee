nconf = require 'nconf'
ds = require 'nedb'
db = {}

loadDb = () ->
	dirName = nconf.get 'DATA_DIR'
	db.seeds = new ds dirName  + '/seeds.db'
	db.seeds.ensureIndex { fieldName: 'url', unique: true }

	db.injectorStatus = new ds dirName  + '/injector_status.db'
	db.injectorStatus.ensureIndex { fieldName: 'crawlId', unique: true }

	db.seeds.loadDatabase()
	db.injectorStatus.loadDatabase()

get = (collection) ->
	db[collection]

exports.get = get
exports.loadDb = loadDb