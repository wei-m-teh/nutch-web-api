restify = require 'restify'
http = require 'http'
nconf = require 'nconf'
router = require './routes/router.coffee'

nconf.argv()
       .env()
       .file { file : './conf/env-dev.json' }
nconf.load()

server = restify.createServer { name: 'nutch-api' }
server.use restify.bodyParser()
server.use restify.queryParser()

router.route server

server.listen process.env.PORT || 3000, process.env.IP | "0.0.0.0", () ->
  console.log '%s listening at %s', server.name, server.url