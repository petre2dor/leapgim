#
# Gesture Controller
#
# Triggers actions based on recipes.
#

class GestureController
    constructor: (config) ->
        @recipes = config.recipes
        @actions = config.actions
        @gestureList = []

    runGesture: (gesture) =>
        @gestureList.push gesture
        resetGestureList = true
        for name, recipe of @recipes
            #check if the gestureList is an exact match the list of gestures from this recipe
            if @recipes[name].gestures.toString() == @gestureList.toString()
                console.log '================== ============= =========== run action ' + @recipes[name].action
                actionController = new ActionController @actions[@recipes[name].action]
                actionController.run()
                break

            #check if gestureList are the beginning of this recipe
            if @recipes[name].gestures.toString().indexOf(@gestureList.toString()) == 0
                console.log 'found partial recipe'
                resetGestureList = false
        if resetGestureList then @resetGestureList()
        console.log '--------------------------------------------------------------------------'
        console.log '--------------------------------------------------------------------------'
        console.log '--------------------------------------------------------------------------'

    resetGestureList: () =>
        console.log '--resetGestureList--'
        @gestureList = []


window.GestureController = GestureController