doc = $(document)
win = $(window)
canvas = $("#canvas")
paper = null
panZoom = null
zoomStep = 0.05
penColor = "#000"
draw_id = null
map = null
map_z_left = -6505 #-208418.39 #-7200.0
map_x_top = 3497.78 #-276504.19 # 2470.0
map_scale_x = 0.3584695932658974
map_scale_z = 0.3310695932658974
zoom_scale = 1.0
map_width = 16500
map_height = 11857
initial_zoom = 6
max_zoom = 19.5

resize = ->
  w = map_width
  h = map_height
  ww = $(window).width()
  wh = $(window).height()
  if ww/wh < w/h
    zoom_scale = ww/w
    cw = ww
    ch = ww * h/w
  else
    zoom_scale = wh/h
    cw = wh * w/h
    ch = wh

  canvas.width(cw)
  canvas.height(ch)
  map.attr({width:cw,height:ch})

instructions = $("#instructions")
window.paper = paper = new Raphael(canvas[0], '100%', '100%')
canvas.css('cursor','move')
map = paper.image("images/map.jpg", 0, 0, map_width, map_height)
resize()
panZoom = paper.panzoom({ initialZoom: initial_zoom, zoomStep:zoomStep, maxZoom: max_zoom, initialPosition: { x: 120, y: 70} })
panZoom.enable()

$(window).resize resize

url = location
socket = io.connect(url)
drawing = false

clients = {}
lines = {}
cursors = {}
locations = {}
current_user = {}
draw_buffer = []

cursor = ->
  paper.circle(2.5, 2.5, 5)

pin = ->
  circle = paper.circle(2.5, 2.5, 5)
  circle.attr({
    'fill' : '#0088ee'
  })
  circle

new_line = (x, y, color='#000') ->
  path_string = 'M' + x + ' ' + y + 'l0 0'
  path = paper.path(path_string)
  path.attr({
    'stroke': color,
    'stroke-linecap': 'round',
    'stroke-linejoin': 'round',
    'stroke-width': 1
  })
  { path:path, path_string: path_string, prev: {x:x,y:y} }


line_to = (line, x, y) ->
  line.path_string += 'l' + (x - line.prev.x) + ' ' + (y - line.prev.y)
  # line.path_string += 'L' + x + ' ' + y
  line.path.attr('path', line.path_string)
  line.prev.x = x
  line.prev.y = y

socket.on "moving", (data) ->
  cursors[data.id] = cursor() unless cursors[data.id]
  cursors[data.id].updated = $.now()
  zoomed = map_to_zoomed_coords data.x, data.z
  cursors[data.id].attr {cx:zoomed.x,cy:zoomed.y}

socket.on "drawing", (data) ->
  unless lines[data.id]
    point = data.points.shift()
    if point?
      zoomed = map_to_zoomed_coords point.x, point.z
      lines[data.id] = new_line(zoomed.x, zoomed.y, data.color)

  line = lines[data.id]
  for point in data.points
    zoomed = map_to_zoomed_coords point.x, point.z
    line_to line, zoomed.x, zoomed.y


$('.tool.color').each (i,el) ->
  $el = $(el)
  $el.css('background-color', $el.attr('data-color'))
  $el.click -> penColor = $el.attr('data-color')

$pen = $('.tool.pen')
$pen.click =>
  if panZoom.enabled
    $pen.addClass('selected')
    panZoom.disable()
    canvas.css('cursor','crosshair')
  else
    $pen.removeClass('selected')
    panZoom.enable()
    canvas.css('cursor','move')

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

$room_form = $('.change-room .room-form')
$room_form.hide()
toggle_change_room = =>
  if $room_form.is(':visible')
    $room_form.slideUp()
  else
    $room_form.slideDown()

$room_button = $room_form.find('.button')
$room_button.on 'click',  =>
  submit_room_form()

$room_name = $room_form.find('.room-name')
$room_name.keyup (e) ->
  if(e.keyCode == 13)
    submit_room_form()

submit_room_form = =>
  room_name = $room_name.val()
  change_room(room_name)

change_room = (name) =>
  window.location = "/#{name}"

$('.change-room a.change-room').click =>
  toggle_change_room()
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
  $users = $('.users')
  $list = $users.find('ul')
  $list.empty()
  for user in users
    if !current_user || user.username != current_user.username
      $li = $('<li>')
      $li.addClass('username')
      $li.attr('data-user-id', user.id)
      $li.text user.username
      $list.append($li)

    unless locations[user.id]
      location = pin()
      location.attr('data-user-id',user.id)
      name_scope = "li[data-user-id='#{user.id}']"
      pin_scope = "path[data-user-id='#{user.id}']"
      locations[user.id] = location

    unless !user.x? || !user.z? || user.x == 0 || user.z == 0
      loc = map_to_zoomed_coords user.x, user.z
      location = locations[user.id]
      location.attr
        cx: loc.x
        cy: loc.y


socket.on "update_user", (user) ->
  current_user = user
  mixpanel.alias(user.id)
  username = current_user.username
  $users = $('.users')
  # $users.find('input.username').val(username)
  # $users.find('input.user-x').val(user.x)
  # $users.find('input.user-z').val(user.z)
  # $current_username = $users.find('.current-user .username')
  # $current_username.text(username)
  # $current_username.attr('data-user-id', user.id)
  $users.find('.names [data-user-id="'+user.id+'"]').remove()
  $.cookie('rustradar.username', username) unless user.generated

socket.on "update_chat", (username, message) ->
  new_chat_message username, message

prev = {}
path = null
path_string = null

begin_path = (x,y, color='#000') ->
  path_string = 'M' + x + ' ' + y + 'l0 0'
  path = paper.path(path_string)
  path.attr({
    'stroke': color,
    'stroke-linecap': 'round',
    'stroke-linejoin': 'round',
    'stroke-width': 1
  })

random = ->
  Math.random().toString()

random_hash = (length) ->
  sha = new jsSHA(random(), "TEXT")
  sha.getHash("SHA-1", "HEX").slice(0,length)

canvas.on "mousedown", (e) ->
  instructions.fadeOut()
  return if panZoom.enabled
  e.preventDefault()
  drawing = true
  draw_id = random_hash(7)
  zoomed = canvas_to_zoomed e.offsetX, e.offsetY
  x = zoomed.x
  y = zoomed.y
  begin_path(x, y, penColor)
  prev.x = x
  prev.y = y

doc.bind "mouseup mouseleave", ->
  send_drawing()
  drawing = false

canvas_to_zoomed = (cx, cy) ->
  pan = panZoom.getCurrentPosition()
  zoom = panZoom.getCurrentZoom()
  zx = cx * (1.0 - (zoomStep * zoom))
  zy = cy * (1.0 - (zoomStep * zoom))
  zx = zx + pan.x
  zy = zy + pan.y
  {x:zx,y:zy}

map_to_zoomed_coords = (mx, mz) ->
  cx = (mz - map_z_left) / map_scale_z
  cy = (mx - map_x_top) / map_scale_x
  {x:cx, y:cy}

zoomed_to_map_coords = (cx, cy) ->
  mx = (cy * map_scale_x) + map_x_top
  mz = (cx * map_scale_z) + map_z_left
  {x:mx, z:mz}

canvas.dblclick (e) ->
  zoomed = canvas_to_zoomed e.offsetX, e.offsetY
  map_coords = zoomed_to_map_coords zoomed.x, zoomed.y
  x = map_coords.x
  z = map_coords.z
  user = {x,z}
  socket.emit('update_user', user)

lastMove = $.now()
doc.on "mousemove", (e) ->
  zoomed = canvas_to_zoomed e.offsetX, e.offsetY
  map_coords = zoomed_to_map_coords zoomed.x, zoomed.y
  $('.map-x').text(map_coords.x.toFixed(2))
  $('.map-z').text(map_coords.z.toFixed(2))
  if $.now() - lastMove > 30
    socket.emit "mousemove",
      x: map_coords.x
      z: map_coords.z
    lastMove = $.now()

  return unless drawing
  draw_buffer.push map_coords
  if $.now() - lastDraw > 300
    send_drawing()

  drawLineTo zoomed.x, zoomed.y

lastDraw = $.now()
send_drawing = ->
  socket.emit "draw",
    points: draw_buffer
    id: draw_id
    color: penColor
  lastDraw = $.now()
  draw_buffer = []

setInterval (->
  for id, c of cursors
    if $.now() - c.updated > 10000
      c.remove()
      delete cursors[id]
), 10000

drawLineTo = (x,y) ->
  path_string += 'l' + (x - prev.x) + ' ' + (y - prev.y)
  path.attr('path', path_string)
  prev.x = x
  prev.y = y

