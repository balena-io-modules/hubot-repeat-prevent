# Description:
#   A hubot script to do nothing
#
# Author:
#   Andrew Lucas (sqweelygig) <andrewl@resin.io> <sqweelygig@gmail.com>
moment = require 'moment'
scopes = {}
timeout = parseInt(process.env.HUBOT_PREVENT_REPEAT_TIMEOUT ? '30')

tidy = ->
	horizon = moment().subtract(timeout, 'minutes')
	for scope, comments of scopes
		for comment, timestamp of comments when timestamp.isBefore horizon
			delete scopes[scope][comment]

module.exports = (robot) ->
	robot.responseMiddleware (context, next, done) ->
		now = moment()
		horizon = moment(now).subtract(timeout, 'minutes')
		comment = context.response.message.text
		scope = context.response.message.metadata?.thread_id ? context.response.message.room
		scopes[scope] ?= {}

		# If the comment isn't in our memory
		if (not scopes[scope][comment]?) or scopes[scope][comment].isBefore(horizon)
			scopes[scope][comment] = now
			next()
		else
			done()

		# Tidy up every 10 percent of the way through the timeout
		_.throttle tidy, timeout * 6000 # (60 * 1000 * 0.1)
