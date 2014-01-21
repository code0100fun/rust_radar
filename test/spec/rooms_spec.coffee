Rooms = require('../../server/rooms')
expect = require('chai').expect

describe 'Rooms', () ->

  beforeEach ->
    @rooms = new Rooms

  describe '#constructor()', ->
    it 'creates a new room list', ->
      expect(@rooms).to.not.be.undefined
    it 'creates a new room list', ->
      expect(@rooms).to.not.be.undefined

  describe '#create(attributes)', ->
    it 'creates a room with the given attributes', ->
      room = @rooms.create {name:'reddit'}
      expect(room.name).to.eq 'reddit'

  describe '#find(attributes)', ->
    beforeEach ->
      @room = @rooms.create {name:'reddit'}

    it 'finds room by id', ->
      found_room = @rooms.find {id:@room.id}
      expect(found_room.name).to.eq 'reddit'

    it 'finds room by name', ->
      found_room = @rooms.find {name:'reddit'}
      expect(found_room.name).to.eq 'reddit'

