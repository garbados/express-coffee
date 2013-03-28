require 'js-yaml'

module.exports = (req, res, next) ->
	root = '../../i18n'
	try
		res.locals.i18n = require "#{root}/#{req.lang}.yaml"
	catch e
		if e.code is 'MODULE_NOT_FOUND'
			res.locals.i18n = require "#{root}/en.yaml"
		else
			throw e
	next()