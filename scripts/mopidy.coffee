# Description
#   Control the mopidy music server
#
# Dependencies:
#   mopidy
#
# Configuration:
#  HUBOT_MOPIDY_WEBSOCKETURL (eg. ws://localhost:6680/mopidy/ws/)
#
# Commands:
#   set volume <v> - set volume to numeric value 0 to 100
#   volume? - show current volume
#   what's playing? - show current song
#
# Author:
#   Johannes Lauinger <jlauinger@d120.de>
#   eriley (https://github.com/eriley


Mopidy = require("mopidy")

mopidy = new Mopidy(webSocketUrl: process.env.HUBOT_MOPIDY_WEBSOCKETURL)

online = false
mopidy.on 'state:online', ->
  online = true
mopidy.on 'state:offline', ->
  online = false

module.exports = (robot) ->

  robot.respond /current playlist\?/i, (msg) ->
    if online
      printTracklist = (tracks) ->
        if tracks
          msg.sendCode (tracks.map (t) -> "#{t.name} from #{t.album.name} by #{t.artists[0].name}").join "\n"
        else
          msg.send "Sorry, can't grab current playlist"
      mopidy.tracklist.getTracks().then printTracklist, console.error.bind(console)
    else
      msg.send "Mopidy is offline"

  robot.respond /play (.+)/i, (msg) ->
    if online
      q = msg.match[1]
      mopidy.library.search({ any: q }).then (result) ->
        unless result.length && result[0].tracks?.length
          msg.reply "Sorry, can't find any track for #{q}"
          return
        track = result[0].tracks[0]
        mopidy.tracklist.add([track], 0).then () ->
          mopidy.tracklist.getTlTracks().then (tlTracks) ->
            mopidy.playback.play tlTracks[0]
            msg.send "Now playing #{track.name} from #{track.album.name} by #{track.artists[0].name}"
    else
      msg.send "Mopidy is offline"

  robot.respond /set volume(?: to)? (\d+)/i, (message) ->
    newVolume = parseInt(message.match[1])
    if online
      console.log mopidy.playback
      mopidy.playback.setVolume(newVolume)
      message.send("Set volume to #{newVolume}")
    else
      message.send('Mopidy is offline')

  robot.respond /volume\?/i, (message) ->
    if online
      printCurrentVolume = (volume) ->
        if volume
          message.send("The Current volume is #{volume}")
        else
          message.send("Sorry, can't grab current volume")
    else
      message.send('Mopidy is offline')
    mopidy.playback.getVolume().then printCurrentVolume, console.error.bind(console)

  robot.respond /what'?s playing/i, (message) ->
    if online
      printCurrentTrack = (track) ->
        if track
          message.send("Currently playing: #{track.name} by #{track.artists[0].name} from #{track.album.name}")
        else
          message.send("No track is playing")
    else
      message.send('Mopidy is offline')
    mopidy.playback.getCurrentTrack().then printCurrentTrack, console.error.bind(console)

  robot.respond /next track/i, (message) ->
    if online
      mopidy.playback.next()
      printCurrentTrack = (track) ->
        if track
          message.send("Now playing: #{track.name} by #{track.artists[0].name} from #{track.album.name}")
        else
          message.send("No track is playing")
    else
      message.send('Mopidy is offline')
    mopidy.playback.getCurrentTrack().then printCurrentTrack, console.error.bind(console)

  robot.respond /mute/i, (message) ->
    if online
      mopidy.playback.setMute(true)
      message.send('Playback muted')
    else
      message.send('Mopidy is offline')

  robot.respond /unmute/i, (message) ->
    if online
      mopidy.playback.setMute(false)
      message.send('Playback unmuted')
    else
      message.send('Mopidy is offline')

  robot.respond /pause music/i, (message) ->
    if online
      mopidy.playback.pause()
      message.send('Music paused')
    else
      message.send('Mopidy is offline')

  robot.respond /resume music/i, (message) ->
    if online
      mopidy.playback.resume()
      message.send('Music resumed')
    else
      message.send('Mopidy is offline')

  robot.respond /shuffle music/i, (message) ->
    if online
      mopidy.tracklist.setRandom(true)
      message.send('Now shuffling')
    else
      message.send('Mopidy is offline')

  robot.respond /stop shuffle/i, (message) ->
    if online
      mopidy.tracklist.setRandom(false)
      message.send('Shuffling has been stopped')
    else
      message.send('Mopidy is offline')
