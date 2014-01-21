User = require('../server/user')
expect = require('chai').expect

describe 'User', () ->

  beforeEach ->
    @user = new User username:'bob',id:'aaa',x:1,z:2,generated:false

  describe '#constructor(attributes)', ->
    it 'creates a new user with the given attributes', ->
      expect(@user.username).to.eq('bob')
      expect(@user.unique).to.eq('bob')
      expect(@user.x).to.eq(1)
      expect(@user.z).to.eq(2)
      expect(@user.generated).to.eq(false)

  describe '#update(attributes)', ->
    it 'updates a users attributes', ->
      @user.update username:'bill',unique:'bill',x:4,z:5,generated:true
      expect(@user.username).to.eq('bill')
      expect(@user.unique).to.eq('bill')
      expect(@user.x).to.eq(4)
      expect(@user.z).to.eq(5)
      expect(@user.generated).to.eq(true)

  describe '#attributes()', ->
    it 'outputs a users attributes', ->
      attributes = @user.attributes()
      expect(attributes.id).to.be.eq('aaa')
      expect(attributes.username).to.eq('bob')
      expect(attributes.x).to.eq(1)
      expect(attributes.z).to.eq(2)
      expect(attributes.generated).to.eq(false)
