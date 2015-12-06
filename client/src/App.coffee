zmq     = require 'zmq'
gui     = require 'nw.gui'

config  = require './etc/config.json'

gestureController = new GestureController config


#Reference to window and tray
win     = gui.Window.get()
tray    = new gui.Tray { title: 'Tray', icon: './asset/img/24.png' }

# define tray menu
menu     = new gui.Menu()
menuItem = new gui.MenuItem {
                    type: "normal"
                    label: 'Show Settings'
                    click: -> win.show()
                }
menu.append menuItem
tray.menu = menu
#minimise to tray
win.on 'minimize', -> this.hide()

socket = zmq.socket('sub')
socket.on 'connect_delay', (fd, ep) ->
    console.log 'connect_delay, endpoint:', ep
    return
socket.on 'connect_retry', (fd, ep) ->
    console.log 'connect_retry, endpoint:', ep
    return
socket.on 'listen', (fd, ep) ->
    console.log 'listen, endpoint:', ep
    return
socket.on 'bind_error', (fd, ep) ->
    console.log 'bind_error, endpoint:', ep
    return
socket.on 'accept', (fd, ep) ->
    console.log 'accept, endpoint:', ep
    return
socket.on 'accept_error', (fd, ep) ->
    console.log 'accept_error, endpoint:', ep
    return
socket.on 'close', (fd, ep) ->
    console.log 'close, endpoint:', ep
    return
socket.on 'close_error', (fd, ep) ->
    console.log 'close_error, endpoint:', ep
    return
socket.on 'disconnect', (fd, ep) ->
    console.log 'disconnect, endpoint:', ep
    return
console.log 'Start monitoring...'
socket.monitor 500, 0

socket.connect config.socket
socket.on 'connect', (fd, ep) ->
    console.log 'connect, endpoint:', ep
    socket.subscribe 'gesture'
    socket.on 'message', (topic, message) =>
        try
            if(topic.toString() == 'gesture')
                gestureController.runGesture(message)
        catch e
            console.log "error", e.message
            console.log "trace", e.stack
        return
    return
