express = require 'express'
routes = require './server/src/routes'
http = require 'http'
path = require 'path'
GraphDb = require './server/src/services/graphdb'
{log} = require './server/src/services/log'
# Connect to DB's
db = new GraphDb process.env.NEO4J_URL || 'http://localhost:7474'

# middleware method to set the database
setDb = (req, res, next) ->
  req.db = db
  next()

# create express app
app = express()
app.configure ->
  app.set 'port', process.env.PORT || 3618
  app.set 'views', './server/views'
  app.set 'view engine', 'jade'
  app.use express.favicon './client/images/favicon.ico'
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  # app.use require('connect-livereload')()
  app.use express.compress()
  app.use express.static './client/vendor'
  app.use express.static './build/assets'
  app.use require('connect-assets')()
app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

# set up routes
# read http://info.apigee.com/Portals/62317/docs/web%20api.pdf before adding routes
app.get '/', routes.index
app.all '/calculations*', express.basicAuth 'admin','aapkop'
app.get '/calculations', routes.calculations
app.get '/objects', setDb, routes.objects
app.get '/relationships', setDb, routes.relationships
app.post '/relationship', setDb, routes.relationship
app.del '/relationship/:obj', setDb, routes.deleteNode
app.del '/relationship/:obj/:rel/:sub', setDb, routes.deleteRelationship

app.get '/clearDB', setDb, routes.clearDB
app.get '/relationships/save', setDb, routes.saveToFile
app.get '/relationships/load', setDb, routes.loadFromFile
app.get '/relationships/load-demo', setDb, routes.loadDemoFromFile

app.post '/graph/cypher', setDb, routes.execCypher
app.get '/graph/edit', setDb, routes.editGraph
app.get '/graphData/arbor', setDb, routes.getGraphDataArbor
app.get '/conclusion/is_a_category', setDb, routes.categories
app.get '/conclusion/relations', setDb, routes.relations
app.get '/conclusion/popular_relationships', setDb, routes.getRelationshipsOrderedByUse
# start listening
app.listen app.get('port'), ->  log.info "server listening on http://localhost:#{app.get 'port'}."