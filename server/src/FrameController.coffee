###
  am o idee.
  în loc să folosesc poziția curentă (și exactă), pot să folosesc media pozițiilor de pe ultimele x frame-uri
###
Leap    = require 'leapjs'
zmq     = require 'zmq'
config  = require '../etc/config.json'


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


# Config key: socket
socket.bindSync config.socket


fingerMap = ["thumb", "index", "middle", "ring", "pinky"]

class GestureController
    constructor: ->
        @currentPossibleGestures = {}

    getGesture: (frame) =>
        extendedFingers = @getExtendedFingers(frame)
#        console.log 'extendedFingers: ' + extendedFingers.toString()
        if frame.gestures.length > 0
            for gesture in frame.gestures
                switch gesture.type
                    when 'circle'
                        pointableID = gesture.pointableIds[0];
                        direction = frame.pointable(pointableID).direction;
                        dotProduct = Leap.vec3.dot(direction, gesture.normal);
                        if extendedFingers.toString() == 'thumb,index'
                            if dotProduct > 0
                                return 'oneFingerRotateClockwise'
                            else
                                return 'oneFingerRotateContraClockwise'
                        if extendedFingers.toString() == 'thumb,index,middle'
                            if dotProduct > 0
                                return 'twoFingersRotateClockwise'
                            else
                                return 'twoFingersRotateContraClockwise'
                    when 'keyTap'
                        return 'keyTap'
                    when 'screenTap'
                        return 'screenTap'
                    when 'swipe'
                        # Classify swipe as either horizontal or vertical
                        isHorizontal = Math.abs(gesture.direction[0]) > Math.abs(gesture.direction[1])
                        #Classify as right-left or up-down
                        if isHorizontal
                            swipeDirection = if gesture.direction[0] > 0 then 'right' else 'left'
                        else
                            swipeDirection = if gesture.direction[1] > 0 then 'up' else 'down'
                        return 'swipe' + swipeDirection[0].toUpperCase() + swipeDirection.slice(1)
                        console.log(swipeDirection)
#        search for openHandHover gesture
        if extendedFingers.toString() == 'thumb,index,middle,ring,pinky'
            hand = frame.hands[0]

#            check if openHandHover is in @currentPossibleGestures
            if @currentPossibleGestures.hasOwnProperty 'openHandHover'
                initialPos  = @currentPossibleGestures.openHandHover.position
                pos         = hand.stabilizedPalmPosition
                max         = config.gestures.openHandHover.maxPalmMovement

                console.log 'Initial x: ', initialPos[0]
                console.log '    new x: ', pos[0]

#                check if the hand was stable enough
                if Math.abs(pos[0] - initialPos[0]) > max
                    console.log 'movement on X greater that max'
                    delete @currentPossibleGestures.openHandHover
                else if Math.abs(pos[1] - initialPos[1]) > max
                    console.log 'movement on Y greater that max'
                    delete @currentPossibleGestures.openHandHover
                else if Math.abs(pos[2] - initialPos[2]) > max
                    console.log 'movement on Z greater that max'
                    delete @currentPossibleGestures.openHandHover
                else
                    if config.gestures.openHandHover.time <= (frame.timestamp - @currentPossibleGestures.openHandHover.timestamp)
                        return 'openHandHover'
                    console.log 'still waiting'
            else
#                add openHandHover is in @currentPossibleGestures
                @currentPossibleGestures.openHandHover = {
                    'timestamp':    frame.timestamp
                    'position':     hand.stabilizedPalmPosition
                }
                console.log 'start waiting for openHandHover', JSON.stringify(@currentPossibleGestures.openHandHover)

#       todo search for another gesture...

        return false

    getExtendedFingers: (frame) =>
        extendedFingers = []
        if frame.hands.length > 0
            hand = frame.hands[0]

            for finger in hand.fingers
                if finger.extended is on
                    extendedFingers.push(fingerMap[finger.type])

        return extendedFingers

gestureController = new GestureController

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
#        clear possible gestures
        gestureController.currentPossibleGestures = {}
#        send to client
        socket.send [
            'gesture'
            gesture
        ]
# Config key: interval
setInterval consume, config.interval
