App.IndexRoute = Ember.Route.extend
  renderTemplate: ->
    @render()
    @render 'users', { outlet: 'users', controller: @controllerFor('users') }
    @render 'chat', { outlet: 'chat', controller: @controllerFor('chat') }
    @render 'currentUser', { outlet: 'currentUser', controller: @controllerFor('currentUser') }
    @render 'map', { outlet: 'map', controller: @controllerFor('map') }
    @render 'rtc', { outlet: 'rtc', controller: @controllerFor('rtc') }
