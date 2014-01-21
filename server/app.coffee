express = require("express")
path = require("path")
app = express()
server = require("http").createServer(app)
io = require("socket.io").listen(server)
Hashids = require("hashids")
haml = require("haml-coffee")
jade = require("jade")
cookie = require('cookie')
Mixpanel = require('mixpanel')
Users = require('./users')

hashes = {}
counter = Math.floor(Math.random() * 1000)
salt = Math.random().toString(36).substring(10)
hashids = new Hashids(salt, 12)
namespace_status = {}
port = process.env.PORT or 9000

appDir = path.join(__dirname, "../app")
if "production" is app.get("env")
  mixpanel_key = "669a02e9b4e6b4efe1eface05261703b"
  buildDir = path.join(__dirname, "../dist")
else
  mixpanel_key = "b8a72ab46f6a411eb4b9aee5e84ad917"
  buildDir = path.join(__dirname, "../.tmp")
  app.use express.errorHandler()

mixpanel = Mixpanel.init(mixpanel_key)

app.use '/scripts', express.static(buildDir + '/scripts')
app.use '/styles', express.static(buildDir + '/styles')
app.use '/images', express.static(buildDir + '/images')
app.use '/bower_components', express.static(buildDir + '/bower_components')
app.set "views", appDir + "/views"
app.engine "hamlc", haml.__express
app.set "view engine", "hamlc"
app.use express.favicon()
app.use express.logger("dev")
app.use express.errorHandler()
app.use staticsPlaceholder = (req, res, next) ->
  next()

generated_rooms = {}

app.get "/", (req, res) ->
  newHash = hashids.encrypt(counter)
  hashes[newHash] = "success"
  counter = counter + 1
  generated_rooms[newHash] = true
  res.redirect "/#{newHash}"

app.get "/:hash", (req, res) ->
  hash = req.params.hash
  generated = !!generated_rooms[hash]
  hashes[hash] = "success"
  unless namespace_status[hash]
    start_chat hash, generated
  res.render "index.hamlc",
    room: hash,
    mixpanel_key: mixpanel_key

server.listen port

start_chat = (namespace, generated_room) ->

  namespace_status[namespace] = { generated: generated_room }

  mixpanel.track "room_created",
    room_name: namespace,
    generated: generated_room

  users = new Users

  chat = io.of("/" + namespace).on("connection", (socket) ->

    default_username = ->
      if socket.handshake.headers && socket.handshake.headers.cookie
        c = cookie.parse(socket.handshake.headers.cookie)
        c['rustradar.username']

    current_user = ->
      users.find id: socket.user_id

    destroy_current_user = ->
      users.destroy current_user().id
      send_all_users()

    user_updated_success = (user) ->
      set_current_user user
      send_current_user()
      send_all_users()

    user_update_invalid = ->
      send_current_user()

    update_user = (attributes) ->
      users.update current_user(),
                  attributes,
                  user_updated_success,
                  user_update_invalid

    send_current_user = ->
      socket.emit "update_user", current_user()

    send_all_users = ->
      chat.emit "update_users", users.all()

    set_current_user = (user) ->
      socket.user_id = user.id

    user_create_success = (user) ->
      set_current_user user
      send_current_user()
      send_all_users()

    user_create_invalid = ->
      users.create({}, user_create_success)

    attributes = {username:default_username()}
    users.create(attributes, user_create_success, user_create_invalid)

    user = current_user()
    mixpanel.track "joined_room",
      room_name: namespace,
      generated_room: generated_room
      username: user.username

    socket.on "mousemove", (data) ->
      socket.broadcast.emit "moving", data

    socket.on "send_chat", (message) ->
      chat.emit "update_chat", current_user().username, message

    socket.on "update_user", (attributes) ->
      update_user attributes
      # socket.emit "updatechat", "SERVER", "you have connected"
      # chat.emit "updatechat", "SERVER", username + " has connected"

    socket.on "disconnect", ->
      destroy_current_user()
      # chat.emit "update_chat", "SERVER", socket.username + " has disconnected"

  )
