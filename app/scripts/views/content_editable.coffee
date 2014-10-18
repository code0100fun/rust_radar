App.ContenteditableView = Ember.View.extend Ember.TargetActionSupport,
  tagName: 'div'
  attributeBindings: ['contenteditable', 'data-placeholder']
  placeholder: ''

  editable: true
  typing: false

  'data-placeholder': (->
    @get 'placeholder'
  ).property('placeholder')

  contenteditable: (->
    if @get('editable') then 'true' else undefined
  ).property('editable')

  valueObserver: (->
    if !@get('typing')
      @setContent()
  ).observes('value')

  didInsertElement: -> @setContent()

  focusOut: -> @set('typing', false)

  keyDown: (e) ->
    if e.keyCode == 13
      @set('typing', false)
      @triggerAction()
    else if !e.metaKey
      @set('typing', true)

  keyUp: (e) ->
    @set('value', @$().text())

  setContent: ->
    @$().html(@get('value'))

