io = require('socket.io-client')
App.ApplicationRoute = Ember.Route.extend
  setupController: (controller, data) ->
    socket = io.connect(window.location)
    controller.set 'socket', socket
