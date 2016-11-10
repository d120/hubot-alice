# Description:
#   create and manage FSS rootlogs
# Commands:
#   hubot rootlog - add a new rootlog
#   hubot what's changed - show rootlogs
# Author:
#   Johannes Lauinger <jlauinger@d120.de>

fs = require 'fs'
moment = require 'moment'

module.exports = (robot) ->

  filename = process.env.HUBOT_ROOTLOG_FILENAME
  roomsFilename = process.env.HUBOT_ROOMS_CONFIG

  rooms = JSON.parse fs.readFileSync roomsFilename, 'utf8'
  room = rooms["test"]

  robot.respond /rootlog (.*)/i, (res) ->
    message = res.match[1]
    date = moment().format()
    username = res.message.user.name

    content = "#{date}: #{username}\n#{message}\n\n"

    fs.appendFile filename, content, (err) ->
      if err
        res.reply "sorry, there was an error :("
      res.reply "Sure thing, I noted it down!"


  robot.respond /(what'?s? )?changed\??/i, (res) ->
    fs.readFile filename, 'utf8', (err, data) ->
      if err
        res.reply "sorry, there was an error :("
      res.reply "Latest changes as of current rootlog:"
      res.sendCode data


  robot.router.post '/hubot/rootlog', (req, res) ->
    data = if req.body.payload? then JSON.parse req.body.payload else req.body
    date = moment().format()

    unless data.message? && data.username?
      res.send '400 Malformed request\n'
      return

    content = "#{date}: #{data.username}\n#{data.message}\n\n"

    fs.appendFile filename, content, (err) ->
      if err
        res.send '500 filesystem error\n'

      robot.messageRoom room, "Heads up: #{data.username} added a new rootlog via HTTP"
      robot.messageCodeRoom room, content
      res.send '200 OK\n'
