userListSteps = ->
  @World = require("../support/world").World

  @Given /^I am on the home page$/, (callback) ->
    @visit "http://localhost:9000/", callback
    
  @Then /^I see the user list$/, (callback) ->
    pageTitle = @browser.text("title")
    if title is pageTitle
      callback()
    else
      callback.fail new Error("Expected to be on page with title " + title)

module.exports = userListSteps
