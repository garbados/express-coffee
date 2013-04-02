Stripe = require('stripe')(process.env.STRIPE_SECRET)
User = require('../models/user')

ensureAuthenticated = (req, res, next) ->
	if not req.isAuthenticated()
		res.send
			error: "unauthenticated"
	else
		next()

# get plans; only collects the first 100 because why would you have more than 4
get_plans = (cb) ->
	stripe.plans.list 100, 0, (e, result) ->
		if e
			throw e
		else
			cb(result.data)

# make stripe routes
stripeify = (app, url_root = "api/v1") ->
	get_plans (results) ->
		app.get [url_root, 'plans'].join('/'), (req, res) ->
			res.send results
		for plan in results
			do (plan) ->
				# get a specific plan
				app.get [url_root, 'plans', plan.id].join('/'), (req, res) ->
					res.send plan
				# unsubscribe
				app.delete [url_root, 'subscribe'].join('/'), (req, res) ->
					ensureAuthenticated req, res, () ->
						User.findById req.user._id, (user) ->
							if user.stripe and user.stripe.customer
								Stripe.customers.cancel_subscription user.stripe.customer.id, (e) ->
									res.send e or 200
							else
								res.send "not a customer", 401
				# subscribe to a new plan or create a customer and subscribe it to a plan
				app.post [url_root, 'subscribe', plan].join('/'), (req, res) ->
					# don't allow subscriptions without authentication
					ensureAuthenticated req, res, () ->
						User.findById req.user._id, (user) ->
							# is the user a customer?
							if user.stripe
								# if the user is already subscribed to this plan, do nothing
								if user.stripe.plan.id is plan.id
									res.send 200
								# otherwise, switch their plan to this one
								else
									Stripe.customers.update_subscription user.stripe.customer.id, {plan: plan.id}, (e, plan) ->
										user.stripe.plan = plan
										user.save (e) ->
											res.send e or 200
							# if not yet a customer, create and subscribe to this plan
							else
								Stripe.customers.create req.body.stripeToken, plan.id, (e, customer) ->
									if e
										res.send e
									else
										user.stripe = 
											customer: customer
											plan: plan
										user.save (e) ->
											res.send e or 200

module.exports =
	stripeify: stripeify
	Stripe: Stripe