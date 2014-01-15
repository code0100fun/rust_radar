
var express = require('express')
    , app = express()
    , server = require('http').createServer(app)
    , io = require('socket.io').listen(server)
    , Hashids = require('hashids')
    , jade = require('jade');

var hashes = {};
var counter = Math.floor(Math.random()*1000);
var salt = Math.random().toString(36).substring(10);
var hashids = new Hashids(salt, 12);
var namespace_status = {};
var buildDir = '/../dist/';
var port = process.env.PORT || 9000;

server.listen(port);

app.set('views', __dirname + buildDir);
// app.set('view engine', 'html');
// app.register('.html', jade);
app.engine('html', require('jade').__express);
app.use('/bower_components', express.static(__dirname + buildDir + 'bower_components'));
app.use('/scripts', express.static(__dirname + buildDir + 'scripts'));
app.use('/styles', express.static(__dirname + buildDir + 'styles'));
app.use('/images', express.static(__dirname + buildDir + 'images'));

app.get('/', function (req, res) {
    var newHash = hashids.encrypt(counter);
    hashes[newHash] = "success";
    counter = counter + 1;
    res.redirect('/' + newHash);
});

app.get('/favicon.ico', function(req, res) {
    // res.render(__dirname + buildDir + 'favicon.ico');
});

app.get('/:hash', function(req, res) {
    var hash = req.params.hash;
    hashes[hash] = "success";
    if (namespace_status[hash] != 'started') {
        start_chat(hash);
        namespace_status[hash] = 'started'
    }
    res.render('index.html', {'room': hash});
});

function start_chat(namespace) {
    console.log("New namespace created: " + namespace);

    var usernames = {};

    var chat = io
    .of('/' + namespace)
    .on('connection', function (socket) {

        socket.on('mousemove', function (data) {
            socket.broadcast.emit('moving', data);
        });

        socket.on('sendchat', function (data) {
            console.log(socket.username + " wrote: " + data);
            chat.emit('updatechat', socket.username, data);
        });

        socket.on('adduser', function(username){
            socket.username = username;
            usernames[username] = username;
            socket.emit('updatechat', 'SERVER', 'you have connected');
            chat.emit('updatechat', 'SERVER', username + ' has connected');
            chat.emit('updateusers', usernames);
        });

        socket.on('disconnect', function(){
            delete usernames[socket.username];
            chat.emit('updateusers', usernames);
            chat.emit('updatechat', 'SERVER', socket.username + ' has disconnected');
        });
    });
}

