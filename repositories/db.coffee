ds = require 'nedb'
db = {}
db.seeds = new ds __dirname  + '/seeds.db'
db.seeds.ensureIndex { fieldName: 'url', unique: true }


db.injectorStatus = new ds __dirname  + '/injector_status.db'
db.injectorStatus.ensureIndex { fieldName: 'crawlId', unique: true }

db.seeds.loadDatabase()
db.injectorStatus.loadDatabase()

module.exports = db