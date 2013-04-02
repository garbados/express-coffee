User = require '../models/user'
hash = require '../helpers/crypto'

# User model's CRUD controller.
module.exports = 

  # Lists all users
  # index: (req, res) ->
  #   User.find {}, (err, users) ->
  #     res.send users
      
  # Creates new user with data from `req.body`, only if user does not currently exist
  create: (req, res) ->
    if not req.isAuthenticated()
      user = new User
        email: req.body.username
        hash: hash.hash(req.body.password)
      user.save (err, user) ->
        if not err
          res.send user
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500
    else
      res.send {message: "User already exists"}
        
  # Gets user by id
  # get: (req, res) ->
  #   User.findById req.params.id, (err, user) ->
  #     if not err
  #       res.send user
  #     else
  #       res.send err
  #       res.statusCode = 500
             
  # Updates user with data from `req.body`
  # update: (req, res) ->
  #   User.findByIdAndUpdate req.params.id, {"$set":req.body}, (err, user) ->
  #     if not err
  #       res.send user
  #     else
  #       res.send err
  #       res.statusCode = 500
    
  # Deletes user by id
  # delete: (req, res) ->
  #   User.findByIdAndRemove req.params.id, (err) ->
  #     if not err
  #       res.send {}
  #     else
  #       res.send err
  #       res.statusCode = 500
      
  