doc = $(document)
win = $(window)
canvas = $("#canvas")
ctx = canvas[0].getContext("2d")
instructions = $("#instructions")
background = new Image()
background.src = "images/map_large.jpg"
background.onload = ->
  canvas[0].width = background.width
  canvas[0].height = background.height
  ctx.drawImage background, 0, 0

url = location
id = Math.round($.now() * Math.random())
socket = io.connect(url)
drawing = false
clients = {}
cursors = {}
canvas[0].width = $(window).width()
canvas[0].height = $(window).height()

current_user = {}

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
  x = ~~$('.users input.user-x').val()
  z = ~~$('.users input.user-z').val()
  user = {username,x,z}
  socket.emit('update_user', user) if !!user.username

toggle_edit_user = =>
  $edit_user = $('.edit-user')
  if $edit_user.is(':visible')
    $edit_user.slideUp()
  else
    $edit_user.slideDown()


$('.users .current-user .username').click =>
  toggle_edit_user()
  false

$chat_field = $('.chat .input input')
$chat_field.keyup (e) ->
  if(e.keyCode == 13)
    message = $chat_field.val()
    $chat_field.val('')
    send_chat message

send_chat = (message) ->
  if !!message
    message = message.slice(0,120)
    socket.emit("send_chat", message)

new_chat_message = (username, message) ->
  $message = $('<p class="message"><span class="username"></span><span> : </span><span class="content"></span></p>')
  $message.find('.username').text(username)
  $message.find('.content').text(message)
  $messages = $('.chat .messages')
  $messages.append($message)
  # TODO - if chat was scrolled to bottom keep it there
  $messages[0].scrollTop = $messages[0].scrollHeight

socket.on "update_users", (users) ->
  $users = $('.users')
  $list = $users.find('ul')
  $list.empty()
  for unique, user of users
    if !current_user || user.username != current_user.username
      $li = $('<li>')
      $li.attr('data-username', user.username)
      $li.text user.username
      $list.append($li)

socket.on "update_user", (user) ->
  console.log 'update_user', user
  current_user = user
  username = current_user.username
  $('.users input.username').val(username)
  $('.users .current-user .username').text(username)
  $('.users .names [data-username="'+username+'"]').remove()
  $.cookie('rustradar.username', username) unless user.generated

socket.on "update_chat", (username, message) ->
  new_chat_message username, message

prev = {}
canvas.on "mousedown", (e) ->
  e.preventDefault()
  drawing = true
  prev.x = e.pageX
  prev.y = e.pageY
  instructions.fadeOut()

doc.bind "mouseup mouseleave", ->
  drawing = false


map_z_top = -7200.0
map_x_left = 2470.0
map_scale = 3.29

map_to_canvas_coords = (mx, mz) ->
  cx = (mz - map_z_top) / map_scale
  cy = (mx - map_x_left) / map_scale
  {x:cx, y:cy}

canvas_to_map_coords = (cx, cy) ->
  mx = (cy * map_scale) + map_x_left
  mz = (cx * map_scale) + map_z_top
  {x:mx, z:mz}

lastEmit = $.now()
doc.on "mousemove", (e) ->
  rect = canvas[0].getBoundingClientRect()
  x = e.clientX - rect.left
  y = e.clientY - rect.top
  map_coords = canvas_to_map_coords x, y
  $('.map-x').text(map_coords.x.toFixed(2))
  $('.map-z').text(map_coords.z.toFixed(2))
  if $.now() - lastEmit > 30
    socket.emit "mousemove",
      x: x
      y: y
      # raw_x: map_coords.x
      # raw_z: map_coords.z
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
