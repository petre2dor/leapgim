zmq     = require 'zmq'

class ZmqController
    constructor: (address) ->
        console.log(address)
        #
        # Socket
        #
        socket = zmq.socket 'pub'
        # Register to monitoring events
        socket.on 'connect', (fd, ep) ->
            console.log 'connect, endpoint:', ep
            return
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

        socket.bindSync address

        return socket

module.exports = ZmqController