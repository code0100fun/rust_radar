doc = $(document)
win = $(window)
canvas = $("#canvas")
ctx = canvas[0].getContext("2d")
mapCanvas = $("#map")
mapCtx = mapCanvas[0].getContext("2d")
instructions = $("#instructions")
background = new Image()
background.src = "images/map.jpg"
background.onload = ->
  mapCanvas[0].width = background.width
  mapCanvas[0].height = background.height
  canvas[0].width = background.width
  canvas[0].height = background.height
  mapCtx.drawImage background, 0, 0

url = location
id = Math.round($.now() * Math.random())
socket = io.connect(url)
drawing = false
clients = {}
cursors = {}
canvas[0].width = $(window).width()
canvas[0].height = $(window).height()

window.socket = socket
socket.on "moving", (data) ->
  cursors[data.id] = $("<div class=\"cursor\">").appendTo("#cursors")  unless data.id of clients
  cursors[data.id].css
    left: data.x
    top: data.y

  drawLine clients[data.id].x, clients[data.id].y, data.x, data.y  if data.drawing and clients[data.id]
  clients[data.id] = data
  clients[data.id].updated = $.now()

$('.users input.button').click =>
  username = $('.users input.username').val()
  socket.emit 'change_name', username

socket.on "update_users", (usernames) ->
  $users = $('.users')
  $list = $users.find('ul')
  $list.empty()
  for unique, user of usernames
    $li = $('<li>')
    $li.text user.username
    $list.append($li)

socket.on "update_username", (data) ->
  username = data.username
  $('.username').text(username)
  $('.users input.username').val(username)
  $.cookie('rustradar.username', username) unless data.generated
  console.log 'default username', data, $.cookie('rustradar.username')

prev = {}
canvas.on "mousedown", (e) ->
  e.preventDefault()
  drawing = true
  prev.x = e.pageX
  prev.y = e.pageY
  instructions.fadeOut()

doc.bind "mouseup mouseleave", ->
  drawing = false

lastEmit = $.now()
doc.on "mousemove", (e) ->
  x = e.pageX
  y = e.pageY
  if $.now() - lastEmit > 30
    socket.emit "mousemove",
      x: x
      y: y
      drawing: drawing
      id: id

    lastEmit = $.now()
  if drawing
    drawLine prev.x, prev.y, x, y
    prev.x = x
    prev.y = y

setInterval (->
  for ident of clients
    if $.now() - clients[ident].updated > 10000
      cursors[ident].remove()
      delete clients[ident]

      delete cursors[ident]
), 10000

drawLine = (fromx, fromy, tox, toy) ->
  ctx.moveTo fromx, fromy
  ctx.lineTo tox, toy
  ctx.stroke()
