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
locations = {}
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


$edit_user = $('.edit-user')
$edit_user.hide()
toggle_edit_user = =>
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

$(document).on 'mouseenter', '.pin', ->
  $el = $(@)
  user_id = $el.attr('data-user-id')
  name_scope = "li[data-user-id='#{user_id}'],a[data-user-id='#{user_id}']"
  $(name_scope).css('color':'red')
  $el.css('background-color':'red')
  false

$(document).on 'mouseleave', '.pin', ->
  $el = $(@)
  user_id = $el.attr('data-user-id')
  name_scope = "li[data-user-id='#{user_id}'],a[data-user-id='#{user_id}']"
  $(name_scope).css('color':'')
  $el.css('background-color':'')
  false

$(document).on 'mouseenter', '.username', ->
  $el = $(@)
  user_id = $el.attr('data-user-id')
  pin_scope = ".pin[data-user-id='#{user_id}']"
  $(pin_scope).css('background-color':'red')
  $el.css('color':'red')
  false

$(document).on 'mouseleave', '.username', ->
  $el = $(@)
  user_id = $el.attr('data-user-id')
  pin_scope = ".pin[data-user-id='#{user_id}']"
  $(pin_scope).css('background-color':'')
  $el.css('color':'')
  false

socket.on "update_users", (users) ->
  locations = {}
  $("#locations").empty()
  $users = $('.users')
  $list = $users.find('ul')
  $list.empty()
  for unique, user of users

    if !current_user || user.username != current_user.username
      $li = $('<li>')
      $li.addClass('username')
      $li.attr('data-user-id', user.id)
      $li.text user.username
      $list.append($li)

    unless locations[user.id]
      $location = $("<div class=\"pin\" data-user-id=\"#{user.id}\">").appendTo("#locations")
      name_scope = "li[data-user-id='#{user.id}']"
      pin_scope = ".pin[data-user-id='#{user.id}']"
      locations[user.id] = $location

    if !user.x? || !user.z? || user.x == 0 || user.z == 0
      $location.hide()
    else
      $location.show()

    loc = map_to_canvas_coords user.x, user.z
    $location = locations[user.id]
    $location.css
      left: loc.x - 7
      top: loc.y - 7


socket.on "update_user", (user) ->
  current_user = user
  username = current_user.username
  $users = $('.users')
  $users.find('input.username').val(username)
  $users.find('input.user-x').val(user.x)
  $users.find('input.user-z').val(user.z)
  $current_username = $users.find('.current-user .username')
  $current_username.text(username)
  $current_username.attr('data-user-id', user.id)
  $users.find('.names [data-user-id="'+user.id+'"]').remove()
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

canvas.dblclick (e) ->
  rect = canvas[0].getBoundingClientRect()
  x = e.clientX - rect.left
  y = e.clientY - rect.top
  map_coords = canvas_to_map_coords x, y
  x = map_coords.x
  z = map_coords.z
  user = {x,z}
  socket.emit('update_user', user)

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
