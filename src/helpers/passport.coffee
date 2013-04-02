passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../models/user'
hash = require './crypto'

passport.use new LocalStrategy (email, password, done) ->
	if email.isEmail()
		User.find {email: email}, (e, user) ->
			if e
				done(e)
			else
				if not user
					done(null, false, {message: "Incorrect Username"})
				else
					if not hash.validate(user.hash, password)
						done(null, false, {message: "Incorrect Password"})
					else
						done(null, user)
	else
		done null, false,
			message: "Invalid Email"

passport.serializeUser (user, done) ->
	done null, user._id

passport.deserializeUser (id, done) ->
	User.findById id, (err, user) ->
		done err, user

passportify = (app, url_root) ->
	app.use (req, res, next) ->
		res.locals.user = req.user
		next()
	app.post [url_root, 'auth/local'].join('/'),
		successRedirect '/'
		failureRedirect '/login'
		failureFlash: true
	app.get '/logout', (req, res) ->
		req.logout()
		res.redirect('/')
	app.get '/login', (req, res) ->
		res.render 'login', {user: req.user}

ensureAuthenticated = (req, res, next) ->
	if not req.isAuthenticated()
		res.redirect '/login' 

module.exports =
	passportify: passportify
	ensureAuthenticated: ensureAuthenticated