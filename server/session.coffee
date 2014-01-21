cookie = require('cookie')

class Session
  constructor: (@socket, @instance) ->
    attributes = {username: @default_username()}
    @instance.users.create attributes, @user_create_success, @user_create_invalid
    @socket.on "mousemove", @mouse_move
    @socket.on "send_chat", @send_chat
    @socket.on "update_user", @update_user
    @socket.on "disconnect", @disconnect
    # user = current_user()
    # mixpanel.track "joined_room",
    #   room_name: namespace,
    #   generated_room: generated_room
    #   username: user.username

  headers: ->
    @socket.handshake.headers

  default_username: ->
    headers = @headers()
    if headers && headers.cookie
      c = cookie.parse(headers.cookie)
      c['rustradar.username']

  destroy_current_user: ->
    @instance.users.destroy @current_user.id
    @instance.send_all_users()
    # chat.emit "update_chat", "SERVER", socket.username + " has disconnected"

  update_user: (attributes) =>
    @instance.users.update @current_user,
                          attributes,
                          @user_updated_success,
                          @user_update_invalid
    # socket.emit "updatechat", "SERVER", "you have connected"
    # chat.emit "updatechat", "SERVER", username + " has connected"

  user_create_success: (user) =>
    @current_user = user
    @user_updated_success()

  user_updated_success: (user) =>
    @send_current_user()
    @instance.send_all_users()

  user_create_invalid: =>
    @instance.users.create {},
                          @user_create_success,
                          @user_create_invalid

  user_update_invalid: => @send_current_user()

  send_current_user: -> @socket.emit "update_user", @current_user

  mouse_move: (data) =>
    @socket.broadcast.emit "moving", data

  send_chat: (message) =>
    @instance.send_chat @current_user, message

  disconnect: =>
    @destroy_current_user()

module.exports = Session
