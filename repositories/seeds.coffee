ds = require 'nedb'
db = {}
db.seeds = new ds __dirname  + '/seeds.db'
db.seeds.ensureIndex { fieldName: 'url', unique: true }
db.seeds.loadDatabase()

module.exports = db