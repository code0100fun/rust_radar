App.UsersController = Ember.ArrayController.extend
  needs: ['application', 'currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser.model')
  socket: Ember.computed.alias('controllers.application.socket')
  init: ->
    @_super()
    @get('socket').on 'update_users', @updateUsers
    @set('content', App.users)

  users: (->
    currentUserId = @get('currentUser.id')
    @get('content').filter (obj, index, enumerable) ->
      obj.get('id') != currentUserId
  ).property('content.length')

  updateUsers: (users) ->
    App.users.clear()
    for u in users
      user = App.findOrCreateUser(u.id)
      user.setProperties(u)
