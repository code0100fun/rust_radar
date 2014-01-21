Users = require('../server/users')
expect = require('chai').expect

describe 'Users', () ->
  beforeEach ->
    @users = new Users()
    @user = @users.create username: 'bob'

  describe '#all()', ->
    it 'returns all users', ->
      users = @users.all()
      expect(users.length).to.eq(1)
      expect(users[0].username).to.eq('bob')

  describe '#create(attributes)', ->
    context 'unique name not taken', ->
      it 'creates a new user with the given username', ->
        expect(@user.username).to.eq('bob')

      it 'adds user to user list', ->
        found_user = @users.first()
        expect(found_user.username).to.eq('bob')

      it 'creates an id hash for user', ->
        found_user = @users.first()
        expect(found_user.id).to.not.be.undefined

      it 'cretes trimmed username', ->
        user = @users.create username: ' Bill '
        found_user = @users.find(id: user.id)
        expect(found_user.unique).to.eq('bill')

    context 'unique name taken', ->
      it 'calls invalid callback', ->
        valid = null
        success = -> valid = true
        invalid = -> valid = false
        @users.create {username: 'bob'}, success, invalid
        expect(valid).to.eq(false)

  describe '#update(user, attributes)', ->

    beforeEach ->
      @old_id = @user.id
      @updated_user = @users.update @user, {username:'bill',x:1,z:2,generated:false}

    it 'does not allow changing of user id', ->
      expect(@updated_user.id).to.eq(@old_id)

    it 'does not change user id', ->
      @updated_user = @users.update @user, {id:'123',username:'bill',x:1,z:2,generated:false}
      expect(@updated_user.id).to.eq(@old_id)

    context 'unique name not taken', ->
      it 'updates the unique name', ->
        expect(@user.unique).to.eq('bill')

      it 'updates the username', ->
        expect(@user.username).to.eq('bill')

      it 'updates the x,z coordinates', ->
        expect(@user.x).to.eq(1)
        expect(@user.z).to.eq(2)

      it 'updates the generated flag', ->
        expect(@user.generated).to.eq(false)

    context 'unique name taken', ->
      it 'calls invalid callback', ->
        user = @users.create {username: 'bob'}
        valid = null
        success = -> valid = true
        invalid = -> valid = false
        @users.update user, {username: 'bill'}, success, invalid
        expect(valid).to.eq(false)

  describe '#first(attributes)', ->
    it 'finds the first user', ->
      @users.list['bob'] = {username:'bob'}
      found_user = @users.first()
      expect(found_user.username).to.eq('bob')

  describe '#find(attributes)', ->
    it 'finds user by unique name', ->
      @user = @users.create username: 'dave', unique: 'dave'
      found_user = @users.find unique: 'dave'
      expect(found_user.username).to.eq('dave')

  describe '#destroy(id)', ->
    it 'remoces user from user list', ->
      @users.destroy @user.id
      found_user = @users.find id: @user.id
      expect(found_user).to.be.undefined

