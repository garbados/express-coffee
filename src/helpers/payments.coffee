Stripe = require('stripe')(process.env.STRIPE_SECRET)
User = require('../models/user')

# get plans
get_plans = (cb) ->
	stripe.plans.list 100, 0, (e, result) ->
		if e
			throw e
		else
			cb(result.data)

# make stripe routes
stripeify = (app, url_root = "api/v1") ->
	get_plans (results) ->
		# create to subscribe to each plan
		for plan in results
			do (plan) ->
				app.post [url_root, 'payments', 'subscribe', plan].join '/', (req, res) ->
					# don't allow subscriptions without authentication
					if not req.isAuthenticated()
						res.send
							error: "unauthenticated"
					else
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