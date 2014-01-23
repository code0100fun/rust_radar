Users = require('./users')
Session = require('./session')
Mixpanel = require('mixpanel')
mixpanel = Mixpanel.init(process.env.mixpanel_key)

class Instance
  constructor: (io, @room) ->
    @users = new Users
    @chat = io.of("/" + @room.name).on("connection", @connection)

  connection: (socket) =>
    new Session socket, @

  send_all_users: ->
    @chat.emit "update_users", @users.all()

  send_chat: (user, message) ->
    @chat.emit "update_chat", user.username, message
    mixpanel.track "chat_sent",
      user_id: user.id
      username: user.username
      room_id: @room.id
      room_name: @room.name
      message: message

module.exports = Instance
