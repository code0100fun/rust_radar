User = require './user'
hash = require('./hash')
Mixpanel = require('mixpanel')
mixpanel = Mixpanel.init(process.env.mixpanel_key)

class Users
  constructor: ->
    @list = {}

  trim_username: (username) ->
    username.slice(0,20)

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
    if attributes.username && user.username != attributes.username
      updated_username = true
      attributes.generated = false
      valid = @validate_unique attributes.username
    unless valid
      invalid() if invalid?
    else
      delete attributes.id
      if updated_username?
        mixpanel.track "update_username",
          previous: user.username
          username: attributes.username
          generated: user.generated
      user.update attributes
      updated_user = @find id: user.id
      success(updated_user) if success?
      if attributes.x? || attributes.z?
        mixpanel.track "update_location",
          previous_x: user.x
          previous_z: user.z
          x: attributes.x
          z: attributes.z
          user_id: updated_user.id
          username: updated_user.username

    updated_user

  validate_unique: (username) ->
    user = @find unique: User.make_unique(username)
    !user

  create: (attributes, success, invalid) ->
    h = hash(7)
    unless attributes.username?
      attributes.generated = true
      attributes.username = "guest_#{h}"
    unique = @validate_unique attributes.username
    unless unique
      invalid() if invalid?
    else
      attributes.id = h
      user = new User(attributes)
      @list[user.id] = user
      success(user) if success?
      mixpanel.track "create_user", user
      user

  first: ->
    @list[Object.keys(@list)[0]]

  destroy: (id) ->
    delete @list[id]

module.exports = Users
