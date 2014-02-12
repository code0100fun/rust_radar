# require('raphael')
require('raphael.pan-zoom')

App.MapView = Ember.View.extend
  classNames: ['map']
  resize: ->
    w = @get('mapWidth')
    h = @get('mapHeight')
    ww = $(window).width()
    wh = $(window).height()
    if ww/wh < w/h
      zoomScale = ww/w
      cw = ww
      ch = ww * h/w
    else
      zoomScale = wh/h
      cw = wh * w/h
      ch = wh
    @set('zoomScale', zoomScale)
    @$().width(cw)
    @$().height(ch)
    map = @get('map')
    map.attr({width:cw,height:ch}) if map?

  didInsertElement: ->
    mapWidth = 16500
    mapHeight = 11857
    initialZoom = 6
    maxZoom = 19.5
    zoomStep = 0.05
    paper = new Raphael(@$()[0], '100%', '100%')
    map = paper.image("images/map.jpg", 0, 0, mapWidth, mapHeight)
    panZoom = paper.panzoom({
      initialZoom: initialZoom,
      zoomStep:zoomStep,
      maxZoom: maxZoom,
      initialPosition: { x: 120, y: 70}
    })
    panZoom.enable()
    $(window).resize($.proxy(@resize, @))
    @set('paper', paper)
    @set('mapWidth', mapWidth)
    @set('mapHeight', mapHeight)
    @set('map', map)
    @set('panZoom', panZoom)
    @resize()
