App.Message = Ember.Object.extend
  username: null
  content: null
  timestamp: null
  init: (username, content, timestamp=$.now()) ->
    @_super()
    @set('username', username)
    @set('content', content)
    @set('timestamp', timestamp)
