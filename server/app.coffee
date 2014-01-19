express = require("express")
path = require("path")
app = express()
server = require("http").createServer(app)
io = require("socket.io").listen(server)
Hashids = require("hashids")
haml = require("haml-coffee")
jade = require("jade")
cookie = require('cookie')

hashes = {}
counter = Math.floor(Math.random() * 1000)
salt = Math.random().toString(36).substring(10)
hashids = new Hashids(salt, 12)
namespace_status = {}
port = process.env.PORT or 9000

appDir = path.join(__dirname, "../app")
if "production" is app.get("env")
  buildDir = path.join(__dirname, "../dist")
else
  buildDir = path.join(__dirname, "../.tmp")
  app.use express.errorHandler()

app.use '/scripts', express.static(buildDir + '/scripts')
app.use '/styles', express.static(buildDir + '/styles')
app.use '/images', express.static(buildDir + '/images')
app.use '/bower_components', express.static(buildDir + '/bower_components')
app.set "views", appDir + "/views"
app.engine "hamlc", haml.__express
app.set "view engine", "hamlc"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session(
  secret: "abc123"
  cookie:
    maxAge: 20000000
)
app.use express.errorHandler()
app.use app.router
app.use staticsPlaceholder = (req, res, next) ->
  next()

app.get "/", (req, res) ->
  newHash = hashids.encrypt(counter)
  hashes[newHash] = "success"
  counter = counter + 1
  res.redirect "/" + newHash

app.get "/:hash", (req, res) ->
  hash = req.params.hash
  hashes[hash] = "success"
  unless namespace_status[hash] is "started"
    start_chat hash
    namespace_status[hash] = "started"
  res.render "index.hamlc",
    room: hash

server.listen port

start_chat = (namespace) ->
  usernames = {}
  chat = io.of("/" + namespace).on("connection", (socket) ->

    default_username = ->
      if socket.handshake.headers
        c = cookie.parse(socket.handshake.headers.cookie)
        c['rustradar.username']

    unique_username = (username) ->
      username.toLowerCase().replace(/^\s\s*/, '').replace(/\s\s*$/, '')

    update_username = (username) ->
      console.log 'update_username', username
      unique = unique_username username
      unless usernames[unique]
        delete usernames[socket.username]
        set_username username, unique
      send_username_updates()

    send_username_updates = ->
      chat.emit "update_users", usernames
      socket.emit "update_username", usernames[socket.username]

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
      console.log 'set_username', username, unique, options
      socket.username = unique
      user = extend {username:username}, options
      usernames[unique] = user

    set_username "guest_#{socket.id}", {generated:true}
    username = default_username() || "guest_#{socket.id}"
    console.log 'username', username, socket.username
    update_username username

    socket.on "mousemove", (data) ->
      socket.broadcast.emit "moving", data

    # socket.on "send_chat", (data) ->
    #   chat.emit "update_chat", socket.username, data

    socket.on "change_name", (username) ->
      update_username username
      # socket.emit "updatechat", "SERVER", "you have connected"
      # chat.emit "updatechat", "SERVER", username + " has connected"

    socket.on "disconnect", ->
      delete usernames[socket.username]
      chat.emit "update_users", usernames
      # chat.emit "update_chat", "SERVER", socket.username + " has disconnected"

  )
