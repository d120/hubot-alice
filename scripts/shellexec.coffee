# Description:
#   execute arbitrary shell code
# Commands:
#   hubot exec - executes shell scripts

exec = require('child_process').exec;

module.exports = (robot) ->

  robot.respond /exec (.*)/, (res) ->
    command = res.match[1]
    exec command, (error, stdout, stderr) ->
      res.reply "Here you go:"
      res.sendCode stdout
