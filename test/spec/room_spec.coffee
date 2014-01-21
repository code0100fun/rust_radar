Room = require('../../server/room')
expect = require('chai').expect

describe 'Room', () ->

  beforeEach ->
    @room = new Room {name:'reddit'}

  describe '#constructor(attributes)', ->

    it 'generates a random hash for the room id', ->
      room = new Room
      expect(room.id).to.not.be.undefined

    context 'given a name', ->
      it 'creates a new room with the given name', ->
        expect(@room.name).to.eq('reddit')

      it 'sets the generated flag to false', ->
        expect(@room.generated).to.eq(false)

    context 'not given a name', ->
      it 'creates a new room using the room id as the room name', ->
        room = new Room
        expect(room.name).to.eq room.id

      it 'sets the generated flag to true', ->
        room = new Room
        expect(room.generated).to.eq(true)

