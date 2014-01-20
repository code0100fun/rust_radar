class User
  constructor: (attributes) ->
    @update attributes

  @make_unique: (username) ->
    username.toLowerCase().replace(/^\s\s*/, '').replace(/\s\s*$/, '')

  update: (attributes) ->
    @username = attributes.username || @username
    @unique = User.make_unique(@username) if @username?
    @id = attributes.id || @id
    @x = attributes.x || @x
    @z = attributes.z || @z
    @generated = if attributes.generated? then attributes.generated else @generated

  attributes: ->
    {@id,@username,@x,@z,@generated}

module.exports = User
