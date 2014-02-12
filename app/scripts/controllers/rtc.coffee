SimpleWebRTC = require 'simplewebrtc'

App.RtcController = Ember.ObjectController.extend
  init: ->
    @_super()
    # webrtc = new SimpleWebRTC
    #   localVideoEl: 'current_user_video'
    #   remoteVideosEl: 'remote_user_videos'
    #   detectSpeakingEvents: true
    #   autoAdjustMic: true

    # webrtc.on 'readyToCall', () ->
    #   webrtc.joinRoom('code0100fun')

    # @set 'webrtc', webrtc

