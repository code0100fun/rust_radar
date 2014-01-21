crypto = require('crypto')

hash = (length) ->
  crypto.createHash('sha1').update(Math.random().toString()).digest('hex').slice(0,length)

module.exports = hash
