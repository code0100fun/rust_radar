hash = require('./hash')
Room = require('./room')
Analytics = require('./analytics')

class Rooms
  constructor: ->
    @list = {}

  all: ->
    room for id, room of @list

  create: (attributes, success, invalid) ->
    room = new Room attributes
    unique = @validate_unique room.name
    unless unique
      invalid() if invalid?
    else
      @list[room.id] = room
      success(room) if success?
      Analytics.track "create_room", room
      room

  unique_room_name: (room_name) ->
    room_name.toLowerCase()

  validate_unique: (room_name) ->
    found = (room for room in @all when unique_room_name(room.name) == unique_room_name(room_name))
    found.length == 0

  find: (attributes) ->
    if attributes.id?
      found = []
      room = @list[attributes.id]
      found.push(room) if room?
    else
      found = @all()
    if attributes.name?
      found = (room for room in found when room.name == attributes.name)

    found[0]

module.exports = Rooms
