zombie = require("zombie")
World = World = (callback) ->
  @browser = new zombie()
  @visit = (url, callback) ->
    @browser.visit url, callback

  callback()

exports.World = World
