###
  am o idee.
  în loc să folosesc poziția curentă (și exactă), pot să folosesc media pozițiilor de pe ultimele x frame-uri
###
Leap    = require 'leapjs'
config  = require '../etc/config.json'
GestureController = require('./GestureController')
ZmqController = require('./ZmqController')

gestureController = new GestureController

console.log config.socket
zmqSocket = new ZmqController config.socket

# Init Leap Motion
leapController = new Leap.Controller (
    inBrowser:              false,
    enableGestures:         true,
    frameEventName:         'deviceFrame',
    background:             true,
    loopWhileDisconnected:  false
)
console.log "Connecting Leap Controller"
leapController.connect()
console.log "Leap Controller connected"

consume = () ->
    frame = leapController.frame()

    # Skip invalid frame processing
    if frame is null
        console.log 'invalid frame'
        return
    gesture = gestureController.getGesture(frame)

    if gesture
        console.log 'send gesture: ' + gesture

        ### #clear possible gestures
        gestureController.currentPossibleGestures = {}###

        #send to client
        zmqSocket.send [
            'gesture'
            gesture
        ]
# Config key: interval
setInterval consume, config.interval
