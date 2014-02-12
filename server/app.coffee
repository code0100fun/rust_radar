express = require("express")
path = require("path")
app = express()
server = require("http").createServer(app)
io = require("socket.io").listen(server)
haml = require("haml-coffee")
jade = require("jade")
cookie = require('cookie')

if "production" is app.get("env")
  process.env.mixpanel_key = "669a02e9b4e6b4efe1eface05261703b"
else
  process.env.mixpanel_key = "b8a72ab46f6a411eb4b9aee5e84ad917"
  app.use express.errorHandler()

buildDir = path.join(__dirname, "../.tmp")

Rooms = require('./rooms')
Instance = require('./instance')
Analytics = require('./analytics')

rooms = new Rooms
port = process.env.PORT or 9000

appDir = path.join(__dirname, "../app")

app.use '/scripts', express.static(buildDir + '/scripts')
app.use '/styles', express.static(buildDir + '/styles')
app.use '/images', express.static(buildDir + '/images')
app.use '/bower_components', express.static(buildDir + '/bower_components')
app.set "views", appDir + "/views"
app.engine "haml", haml.__express
app.set "view engine", "hamlc"
app.use express.favicon()
app.use express.logger("dev")
app.use express.errorHandler()
app.use staticsPlaceholder = (req, res, next) ->
  next()

app.get "/", (req, res) ->
  room = rooms.create()
  res.redirect "/#{room.id}"

app.get "/:room_name", (req, res) ->
  room_name = req.params.room_name
  room = rooms.find name:room_name
  unless room?
    room = rooms.create name:room_name
    Analytics.track "room_created",room
  room.insance ?= new Instance io, room

  res.render "index.haml",
    room: room.name,
    mixpanel_key: process.env.mixpanel_key

server.listen port
