moment = require('moment')

App.FromNowView = Ember.View.extend
  tagName: 'span'
  classNames: ['relative-time']
  template: Ember.Handlebars.compile '{{view.content}}'
  content: (->
    text = moment(@get('value')).fromNow()
    text.replace(/a few/, '')
      .replace(/second/,'sec')
      .replace(/minute/,'min')
      .replace(/hour/,'hr')
      .trim()
  ).property('value')
  didInsertElement: ->
    @tick()
  tick: ->
    nextTick = Ember.run.later @, ->
      @notifyPropertyChange('value')
      @tick()
    , 1000
    @set 'nextTick', nextTick
  willDestroyElement: ->
    nextTick = @get('nextTick')
    Ember.run.cancel(nextTick)
