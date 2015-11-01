#
# Gesture Controller
#
# Parses signs (leapgim's own gestures) and triggers actions based on recipes.
#

config = window.config
manager = window.actionHero

class GestureController
    constructor: ->
        @signs = window.config.signs
        @recipes = window.config.recipes
        @currentSign = 
            name:               false #e.g. openSteadyHand
            startedTime:        0 #timespamp
            initialPosition:    0
        # Milliseconds. Release mouse buttons if no new data is received during this time frame.
        #@timeout = window.config.timeout

    assertSign: (signName, signData, frameData) =>
        # Assert true unless a filter statement is found
        sign_ok = true
        
        console.log 'assertSign: ' + signName

        for handModel in frameData.hands
            if signData.minTime
                # if we are watching this sign now
                if @currentSign.name = signName
                    now = new Date()
                    if signData.minTime < now.getTime() - @currentSign.startedTime
                        console.log 'here !'
                        sign_ok = false
            if signData.maxHandShake
                # if we are watching this sign now
                if @currentSign.name = signName
                    if Math.abs(@currentSign.initialPosition.x - handModel.position.x) > signData.maxHandShake
                        console.log 'here !'
                        sign_ok = false
                    if Math.abs(@currentSign.initialPosition.y - handModel.position.y) > signData.maxHandShake
                        console.log 'here !'
                        sign_ok = false
                    if Math.abs(@currentSign.initialPosition.z - handModel.position.z) > signData.maxHandShake
                        console.log 'here !'
                        sign_ok = false
            if(signData.grab)
                grabStrength = handModel.grabStrength
                if(signData.grab.min)
                    if(grabStrength < signData.grab.min)
                        console.log 'here !'
                        sign_ok = false
                if(signData.grab.max)
                    if(grabStrength > signData.grab.max)
                        console.log 'here !'
                        sign_ok = false
            if(signData.pinch)
                pinchStrength = handModel.pinchStrength
                pincher = handModel.pinchingFinger

                if(signData.pinch.pincher)
                    if (signData.pinch.pincher != pincher)
                        console.log 'here !'
                        sign_ok = false
                if(signData.pinch.min)
                    if(pinchStrength < signData.pinch.min)
                        console.log 'here !'
                        sign_ok = false
                if(signData.pinch.max)
                    if(pinchStrength > signData.pinch.max)
                        console.log 'here !'
                        sign_ok = false
            if(signData.extendedFingers)
                extendedFingers = signData.extendedFingers
                if(extendedFingers.indexFinger is not undefined)
                    if extendedFingers.indexFinger != handModel.extendedFingers.indexFinger
                        console.log 'here !'
                        sign_ok = false
                if(extendedFingers.middleFinger is not undefined)
                    if extendedFingers.middleFinger != handModel.extendedFingers.middleFinger
                        console.log 'here !'
                        sign_ok = false
                if(extendedFingers.ringFinger is not undefined)
                    if extendedFingers.ringFinger != handModel.extendedFingers.ringFinger
                        console.log 'here !'
                        sign_ok = false
                if(extendedFingers.pinky is not undefined)
                    if extendedFingers.pinky != handModel.extendedFingers.pinky
                        console.log 'here !'
                        sign_ok = false
                if(extendedFingers.thumb is not undefined)
                    if extendedFingers.thumb != handModel.extendedFingers.thumb
                        console.log 'here !'
                        sign_ok = false
        return sign_ok

    parseGestures: (model) =>
        manager = window.actionHero
        manager.position = model.hands[0].position
        # Timeout handling
        #@timestamp = model.timestamp
        #if(@timer)
        #    clearTimeout(@timer)
        #@timer = setTimeout()

        validSign = false
        for signName,signData of @signs
            if(@assertSign(signName, signData, model))
                console.log 'valid sign: ' + signName
                @currentSign = 
                    name:               signName
                    startedTime:        new Date().getTime()
                    #temporarely get the posision of the first hand, maybe we need both.. 
                    initialPosition:    model.hands[0].position
                console.log 'current sign data: ', JSON.stringify @currentSign
                validSign = signName
                break
        if !validSign
            @currentSign = 
                    name:               false
                    startedTime:        0
                    initialPosition:    0

        console.log 'validSign: ' + validSign

        # TODO: Figure out tear down mechanism
        for recipeName, recipe of @recipes
            if recipe.sign == validSign
                manager = window.actionHero
                manager.executeAction(recipe.action)

window.GestureController = GestureController
