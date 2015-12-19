class GestureController
    constructor: ->
        @currentPossibleGestures = {}
        @fingerMap = ["thumb", "index", "middle", "ring", "pinky"]

    getGesture: (frame) =>
        if frame.hands.length > 0
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
            #search for openHandHover gesture
            if extendedFingers.toString() == 'thumb,index,middle,ring,pinky'
                hand = frame.hands[0]

                #check if openHandHover is in @currentPossibleGestures
                if @currentPossibleGestures.hasOwnProperty 'openHandHover'
                    initialPos  = @currentPossibleGestures.openHandHover.position
                    pos         = hand.stabilizedPalmPosition
                    max         = config.gestures.openHandHover.maxPalmMovement

                    #check if the hand was stable enough
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
                        ### how long since started watching this gesture ###
                        time = frame.timestamp - @currentPossibleGestures.openHandHover.timestamp
                        console.log 'time: ' + time
                        ### is time in the range? ###
                        if (time >= config.gestures.openHandHover.minTime) and (time <= config.gestures.openHandHover.maxTime)
                            ### gesture detected ###
                            delete @currentPossibleGestures.openHandHover
                            return 'openHandHover'
                        else if time > config.gestures.openHandHover.maxTime
                            ### over max time, stop watching gesture ###
                            console.log 'over max time'
                            delete @currentPossibleGestures.openHandHover
                else
#add openHandHover is in @currentPossibleGestures
                    @currentPossibleGestures.openHandHover =
                        timestamp:    frame.timestamp
                        position:     hand.stabilizedPalmPosition

                #check if openHand is in @currentPossibleGestures
                if @currentPossibleGestures.hasOwnProperty 'openHand'
                    initialPos  = @currentPossibleGestures.openHand.position
                    pos         = hand.stabilizedPalmPosition
                    max         = config.gestures.openHand.maxPalmMovement

                    #check if the hand was stable enough
                    if Math.abs(pos[0] - initialPos[0]) > max
                        console.log 'movement on X greater that max'
                        delete @currentPossibleGestures.openHand
                    else if Math.abs(pos[1] - initialPos[1]) > max
                        console.log 'movement on Y greater that max'
                        delete @currentPossibleGestures.openHand
                    else if Math.abs(pos[2] - initialPos[2]) > max
                        console.log 'movement on Z greater that max'
                        delete @currentPossibleGestures.openHand
                    else
                        ### how long since started watching this gesture ###
                        time = frame.timestamp - @currentPossibleGestures.openHand.timestamp
                        ### is time in the range? ###
                        if (time >= config.gestures.openHand.minTime) and (time <= config.gestures.openHand.maxTime)
                            ### gesture detected ###
                            delete @currentPossibleGestures.openHand
                            return 'openHand'
                        else if time > config.gestures.openHand.maxTime
                            ### over max time, stop watching gesture ###
                            console.log 'over max time'
                            delete @currentPossibleGestures.openHand
                else
#add openHand is in @currentPossibleGestures
                    @currentPossibleGestures.openHand =
                        timestamp:    frame.timestamp
                        position:     hand.stabilizedPalmPosition

            if extendedFingers.toString() == 'index,pinky'
                return 'rock'

            if extendedFingers.toString() == ''
                return 'closeFist'


            return false

    getExtendedFingers: (frame) =>
        extendedFingers = []
        if frame.hands.length > 0
            hand = frame.hands[0]

            for finger in hand.fingers
                if finger.extended is on
                    extendedFingers.push(@fingerMap[finger.type])

        return extendedFingers

module.exports = GestureController;