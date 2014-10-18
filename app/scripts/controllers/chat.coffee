App.ChatController = Ember.ArrayController.extend
  needs: ['application', 'currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser.model')
  socket: Ember.computed.alias('controllers.application.socket')
  init: ->
    @_super()
    @get('socket').on 'update_chat', $.proxy(@onMessage, @)

  actions:
    sendChat: ->
      @newMessage(@get('text'))
      @set('text', '')

  text: ''
  messages: Em.A()

  onMessage: (username, message) ->
    message = new App.Message(username, message)
    @get('messages').pushObject message

  newMessage: (message) ->
    @get('socket').emit('send_chat', message)

