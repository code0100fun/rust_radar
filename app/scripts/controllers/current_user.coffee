App.CurrentUserController = Ember.ObjectController.extend
  needs: ['application']
  socket: Ember.computed.alias('controllers.application.socket')
  init: ->
    @_super()
    @get('socket').on 'update_user', $.proxy(@updateUser, @)

  updateUser: (user) ->
    userRecord = App.findOrCreateUser(user.id)
    userRecord.setProperties(user)
    @set('content', userRecord)
