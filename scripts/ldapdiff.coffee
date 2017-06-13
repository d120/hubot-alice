# Description:
#   Receive LDAP diffs and show them to the test room
# Commands:
# Author:
#   Johannes Lauinger <jlauinger@d120.de>

fs = require 'fs'

module.exports = (robot) ->

  roomsFilename = process.env.HUBOT_ROOMS_CONFIG
  rooms = JSON.parse fs.readFileSync roomsFilename, 'utf8'
  testRoom = rooms["test"]

  robot.router.post '/hubot/ldif', (req, res) ->
    data = if req.body.payload? then JSON.parse req.body.payload else req.body
    room = rooms[data.room]

    robot.messageRoom testRoom, "Lülülü, just the difference of yesterday's and today's LDAP :)"
    robot.messageCodeRoom testRoom, data.diff
    res.send '200 OK'
