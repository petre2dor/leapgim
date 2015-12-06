#
# Gesture Controller
#
# Triggers actions based on recipes.
#

class GestureController
    constructor: (config) ->
        @recipes = config.recipes
        @actions = config.actions

    runGesture: (gesture) =>
        for name, recipe of @recipes
#            console.log 'gesture: ' + gesture
#            console.log 'gestures: ' + @recipes[name].gestures.toString()
#            console.log 'index: ' + @recipes[name].gestures.toString().indexOf gesture
            if @recipes[name].gestures.toString().indexOf(gesture) == 0
                actionController = new ActionController @actions[@recipes[name].action]
                console.log 'run action'
                actionController.run()
                break

window.GestureController = GestureController