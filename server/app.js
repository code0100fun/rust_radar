
var express = require('express')
    , app = express()
    , server = require('http').createServer(app)
    , io = require('socket.io').listen(server);

var port = process.env.PORT || 9000;
server.listen(9000);

app.use('/', express.static(__dirname + '/../dist/'));

console.log(__dirname + '/../dist/');
var rooms = {};
io.sockets.on('connection', function (socket) {

    socket.on('mousemove', function (data) {

        // This line sends the event (broadcasts it)
        // to everyone except the originating client.
        socket.broadcast.emit('moving', data);
    });
});
