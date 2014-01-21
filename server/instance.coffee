Users = require('./users')
Session = require('./session')

class Instance
  constructor: (io, @room) ->
    @users = new Users
    @chat = io.of("/" + @room.name).on("connection", @connection)
    # mixpanel.track "room_created",
    #   room_name: namespace,
    #   generated: generated_room

  connection: (socket) =>
    new Session socket, @

  send_all_users: ->
    @chat.emit "update_users", @users.all()

  send_chat: (user, message) ->
    @chat.emit "update_chat", user.username, message

module.exports = Instance
