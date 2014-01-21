hash = require('./hash')

class Room
  constructor: (attributes={}) ->
    @generated = !attributes.name?
    @id = hash(12)
    @name = attributes.name || @id

module.exports = Room
