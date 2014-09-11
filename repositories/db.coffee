nconf = require 'nconf'
ds = require 'nedb'
db = {}

jobStatus = {}
jobStatus.IN_PROGRESS = 0
jobStatus.SUCCESS = 1
jobStatus.FAILURE = -1

jobStatus.INJECTOR = 'INJECTOR'
jobStatus.GENERATOR = 'GENERATOR'
jobStatus.FETCHER = 'FETCHER'
jobStatus.PARSER = 'PARSER'
jobStatus.UPDATEDB = 'UPDATEDB'
jobStatus.SOLRINDEX = 'SOLRINDEX'
jobStatus.SOLRDELETEDUPS = 'SOLRDELETEDUPS'

loadDb = () ->
	dirName = nconf.get 'DATA_DIR'
	db.seeds = new ds dirName  + '/seeds.db'
	db.seeds.ensureIndex { fieldName: 'url', unique: true }

	db.nutchStatus = new ds dirName  + '/nutch_status.db'
	db.nutchStatus.ensureIndex { fieldName: 'identifier' }
	db.nutchStatus.ensureIndex { fieldName: 'jobName' }

	db.nutchStatus.loadDatabase()
	db.seeds.loadDatabase()

get = (collection) ->
	db[collection]

exports.get = get
exports.loadDb = loadDb
exports.jobStatus = jobStatus