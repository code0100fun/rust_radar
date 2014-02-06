App = Ember.Application.create()
App.users = Em.A()

App.Router.map ->
  # @route 'room', { path: '/:room_id' }

App.User = Ember.Object.extend({
})


App.IndexRoute = Ember.Route.extend({
  renderTemplate: ->
    @render()
    @render 'users', { outlet: 'users', controller: @controllerFor('users') }
    @render 'currentUser', { outlet: 'currentUser', controller: @controllerFor('currentUser') }
    @render 'map', { outlet: 'map', controller: @controllerFor('map') }
})

App.ApplicationRoute = Ember.Route.extend({
  setupController: (controller, data) ->
    socket = io.connect(window.location)
    controller.set 'socket', socket
})

App.ApplicationController = Ember.Controller.extend({
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser.model')
})

App.ApplicationView = Ember.View.extend({
  classNames: ['container']
})

App.MapController = Ember.Controller.extend({

})

App.MapView = Ember.View.extend({
  classNames: ['map']
  resize: ->
    w = @get('mapWidth')
    h = @get('mapHeight')
    ww = $(window).width()
    wh = $(window).height()
    if ww/wh < w/h
      zoomScale = ww/w
      cw = ww
      ch = ww * h/w
    else
      zoomScale = wh/h
      cw = wh * w/h
      ch = wh
    @set('zoomScale', zoomScale)
    @$().width(cw)
    @$().height(ch)
    map = @get('map')
    map.attr({width:cw,height:ch}) if map?

  didInsertElement: ->
    mapWidth = 16500
    mapHeight = 11857
    initialZoom = 6
    maxZoom = 19.5
    zoomStep = 0.05
    paper = new Raphael(@$()[0], '100%', '100%')
    map = paper.image("images/map.jpg", 0, 0, mapWidth, mapHeight)
    panZoom = paper.panzoom({
      initialZoom: initialZoom,
      zoomStep:zoomStep,
      maxZoom: maxZoom,
      initialPosition: { x: 120, y: 70}
    })
    panZoom.enable()
    $(window).resize($.proxy(@resize, @))
    @set('paper', paper)
    @set('mapWidth', mapWidth)
    @set('mapHeight', mapHeight)
    @set('map', map)
    @set('panZoom', panZoom)
    @resize()
})

App.CurrentUserController = Ember.ObjectController.extend({
  needs: ['application']
  socket: Ember.computed.alias('controllers.application.socket')
  init: ->
    @get('socket').on 'update_user', @updateUser

  updateUser: (user) ->
    console.log 'user', user
    user = App.users.findBy('id', u.id)
    @set('model', user)
})

App.UsersController = Ember.ArrayController.extend({
  needs: ['application', 'currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser.model')
  socket: Ember.computed.alias('controllers.application.socket')
  init: ->
    @get('socket').on 'update_users', @updateUsers

  users: App.users

  updateUsers: (users) ->
    App.users.clear()
    for u in users
      user = App.users.findBy('id', u.id)
      if user?
        user.set('username', u.username)
        user.set('generated', u.generated)
      else
        user = App.User.create u
        App.users.pushObject(user)

  # currentUser: Ember.computed.alias('currentUser.model')
})


window.App = App



# webrtc = new SimpleWebRTC({
#   localVideoEl: 'localVideo',
#   remoteVideosEl: 'remoteVideos',
#   autoRequestMedia: true
# })

# console.log 'ready handler'
# webrtc.on('readyToCall', () ->
#   console.log 'call room'
#   webrtc.joinRoom('code0100fun')
# )
