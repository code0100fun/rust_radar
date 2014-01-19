express = require("express")
path = require("path")
app = express()
server = require("http").createServer(app)
io = require("socket.io").listen(server)
Hashids = require("hashids")
haml = require("haml-coffee")
jade = require("jade")
cookie = require('cookie')
crypto = require('crypto')
Mixpanel = require('mixpanel')

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

  usernames = {}
  chat = io.of("/" + namespace).on("connection", (socket) ->

    shasum = crypto.createHash('sha1')

    default_username = ->
      if socket.handshake.headers && socket.handshake.headers.cookie
        c = cookie.parse(socket.handshake.headers.cookie)
        c['rustradar.username']

    generate_username = ->
      shasum.update socket.id
      hash = shasum.digest('hex').slice(0,7)
      "guest_#{hash}"

    trim_username = (username) ->
      username.slice(0,20)

    unique_username = (username) ->
      username.toLowerCase().replace(/^\s\s*/, '').replace(/\s\s*$/, '')

    get_user = ->
      usernames[socket.username]

    delete_user = ->
      delete usernames[socket.username]

    update_username = (username) ->
      username = trim_username username
      unique = unique_username username
      unless usernames[unique]
        delete_user()
        set_username username, unique
      send_username_updates()

    send_username_updates = ->
      chat.emit "update_users", usernames
      socket.emit "update_username", get_user()

    extend = (target) ->
      sources = [].slice.call(arguments, 1)
      sources.forEach (source) ->
        for prop of source
          target[prop] = source[prop]
      target

    set_username = (username, unique=username, options={}) ->
      if typeof(unique) == 'object'
        options = unique
        unique = undefined
      unique ?= username
      socket.username = unique
      user = extend {username:username}, options
      usernames[unique] = user

    generated_username = generate_username()
    set_username generated_username, {generated:true}
    username = default_username() || generated_username
    update_username username

    user = get_user()
    mixpanel.track "update_username",
      username: user.username
      generated: user.generated

    mixpanel.track "joined_room",
      room_name: namespace,
      generated_room: generated_room
      username: user.username

    socket.on "mousemove", (data) ->
      socket.broadcast.emit "moving", data

    # socket.on "send_chat", (data) ->
    #   chat.emit "update_chat", socket.username, data

    socket.on "change_name", (username) ->
      old_username = get_user().username
      update_username username
      user = get_user()
      mixpanel.track "update_username",
        previous: old_username
        username: user.username
        generated: user.generated
      # socket.emit "updatechat", "SERVER", "you have connected"
      # chat.emit "updatechat", "SERVER", username + " has connected"

    socket.on "disconnect", ->
      delete usernames[socket.username]
      chat.emit "update_users", usernames
      # chat.emit "update_chat", "SERVER", socket.username + " has disconnected"

  )
