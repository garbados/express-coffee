{stripeify} = require('./helpers/payments')

#### Routes

module.exports = (app, url_root = "/api/v1") ->
  # Index
  app.all '/', (req, res, next) ->
    routeMvc('index', 'index', req, res, next)

  ## Traditional REST
  app.get "#{url_root}/:controller" , (req, res, next) ->
    routeMvc(req.params.controller, "index",req,res, next)

  app.post "#{url_root}/:controller", (req, res, next) ->
    routeMvc(req.params.controller, 'create', req, res, next)    

  app.get "#{url_root}/:controller/:id" , (req, res, next) ->
    routeMvc(req.params.controller, 'get', req, res, next)

  app.put "#{url_root}/:controller/:id" , (req, res, next) ->
    routeMvc(req.params.controller, 'update', req, res, next)

  app.delete "#{url_root}/:controller/:id" , (req, res, next) ->
    routeMvc(req.params.controller, 'delete', req, res, next)

  ## Ghetto Admin Panel -- accessible only in development
  app.configure 'development', ->
    #   - _/**:controller**/**:method**_ -> controllers/***:controller***/***:method*** method
    app.all "#{url_root}/:controller/:method" , (req, res, next) ->
      routeMvc(req.params.controller, req.params.method, req,res,next)

    #   - _/**:controller**/**:method**/**:id**_ -> controllers/***:controller***/***:method*** method with ***:id*** param passed
    app.all "#{url_root}/:controller/:method/:id" , (req, res, next) ->
      routeMvc(req.params.controller, req.params.method,req,res, next)

  # helper routes
  stripeify app, url_root

  # If all else failed, show 404 page
  app.all '/*', (req, res) ->
    console.warn "error 404: ", req.url
    res.statusCode = 404
    res.render '404', 404

# render the page based on controller name, method and id
routeMvc = (controllerName, methodName, req, res, next) ->
  controllerName = 'index' if not controllerName?
  controller = null
  try
    controller = require "./controllers/" + controllerName
  catch e
    console.warn "controller not found: " + controllerName, e
    next()
    return
  data = null
  if typeof controller[methodName] is 'function'
    actionMethod = controller[methodName].bind controller
    actionMethod req, res, next
  else
    console.warn 'method not found: ' + methodName
    next()
