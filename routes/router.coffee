crawler = require './crawler.coffee' 

route = (server) ->
   server.post '/crawler/inject', crawler.inject
   server.get '/crawler/urls', crawler.getUrls
   server.post '/crawler/urls', crawler.createUrl
   server.del '/crawler/urls', crawler.deleteUrl

exports.route = route