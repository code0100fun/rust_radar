User = require './user'
crypto = require('crypto')

class Users
  constructor: ->
    @list = {}

  trim_username: (username) ->
    username.slice(0,20)

  @random_hash: ->
    crypto.createHash('sha1').update(Math.random().toString()).digest('hex').slice(0,7)

  all: ->
    user for id, user of @list

  find: (attributes) ->
    if attributes.id?
      found = []
      user = @list[attributes.id]
      found.push(user) if user?
    else
      found = @all()
    if attributes.unique?
      found = (user for user in found when user.unique == attributes.unique)

    found[0]

  update: (user, attributes, success, invalid) ->
    valid = true
    if user.username != attributes.username
      attributes.generated = false
      valid = @validate_unique attributes.username
    unless valid
      console.log 'invalid', @list
      invalid() if invalid?
    else
      console.log 'valid', user, attributes
      delete attributes.id
      user.update attributes if valid
      success(user) if success?
      # mixpanel.track "update_username",
      #   previous: old_username
      #   username: user.username
      #   generated: user.generated

    console.log 'after update', user
    @find id:user.id

  validate_unique: (username) ->
    user = @find unique: User.make_unique(username)
    !user

  create: (attributes, success, invalid) ->
    hash = Users.random_hash()
    unless attributes.username?
      attributes.generated = true
      attributes.username = "guest_#{hash}"
    unique = @validate_unique attributes.username
    unless unique
      console.log 'invalid', @list
      invalid() if invalid?
    else
      attributes.id = hash
      user = new User(attributes)
      @list[user.id] = user
      success(user) if success?
      user

  first: ->
    @list[Object.keys(@list)[0]]

  destroy: (id) ->
    delete @list[id]

module.exports = Users
